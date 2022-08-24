
-- 1. What is the total amount each customer spent at the restaurant?

select sales.customer_id, sum(menu.price) as "Amount Spent"
from dannys_diner.sales as sales join dannys_diner.menu as menu
on sales.product_id = menu.product_id
group by customer_id
order by customer_id;

-- 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date)
from dannys_diner.sales
group by customer_id
order by customer_id;

-- 3. What was the first item from the menu purchased by each customer?

with ordered as
	( select customer_id, order_date, product_name,
	  dense_rank() over(partition by sales.customer_id
	  order by sales.order_date) as rank
	  from dannys_diner.sales join dannys_diner.menu
	  on sales.product_id = menu.product_id
	 )
select customer_id, product_name
from ordered
where rank = 1
group by customer_id, product_name

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select menu.product_name, count(menu.product_name)
from dannys_diner.sales as sales join dannys_diner.menu
on sales.product_id = menu.product_id
group by product_name
order by count desc;

-- 5 Which item was the most popular for each customer?

with customer as (
select customer_id, product_id,
dense_rank() over (partition by customer_id
order by product_id)
from dannys_diner.sales
)

select product_name, count(dense_rank)
from customer join dannys_diner.menu
on customer.product_id = menu.product_id
group by product_name;

-- 6 Which item was purchased first by the customer after they became a member?

with after_date as
(
select sales.customer_id, product_id, order_date,
dense_rank() over(partition by sales.customer_id
order by order_date)
from dannys_diner.sales right join dannys_diner.members
on sales.customer_id = members.customer_id
where order_date > join_date
)

select after_date.customer_id, product_name, order_date
from after_date join dannys_diner.menu
on after_date.product_id = menu.product_id
where dense_rank = 1
order by order_date

-- 7. Which item was purchased just before the customer became a member?

with before_member as
(
select sales.customer_id, product_id, order_date,
dense_rank() over(partition by sales.customer_id
order by order_date)
from dannys_diner.sales right join dannys_diner.members
on sales.customer_id = members.customer_id
where order_date < join_date
)

select before_member.customer_id, product_name, order_date
from before_member join dannys_diner.menu
on before_member.product_id = menu.product_id
where dense_rank = 1
order by customer_id

-- 8. What is the total items and amount spent for each member before they became a member?

with total_before as 
(
select sales.customer_id, sales.product_id, order_date, price
from dannys_diner.menu join dannys_diner.sales
on sales.product_id = menu.product_id
right join dannys_diner.members
on sales.customer_id = members.customer_id
where order_date < join_date
)

select customer_id, count(distinct(product_id)), sum(price)
from total_before
group by customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier how many points would each customer have?



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi -
-- how many points do customer A and B have at the end of January?
