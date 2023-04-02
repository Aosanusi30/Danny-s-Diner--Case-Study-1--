--- Run from my Database 'dannys_diner'
use dannys_diner

-- Case Study Questions
-- Each of the following case study questions can be answered using a single SQL statement:

-- What is the total amount each customer spent at the restaurant?
-- How many days has each customer visited the restaurant?
-- What was the first item from the menu purchased by each customer?
-- What is the most purchased item on the menu and how many times was it purchased by all customers?
-- Which item was the most popular for each customer?
-- Which item was purchased first by the customer after they became a member?
-- Which item was purchased just before the customer became a member?
-- What is the total items and amount spent for each member before they became a member?
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
	-- how many points would each customer have?
-- In the first week after a customer joins the program (including their join date) 
	-- they earn 2x points on all items, not just sushi - 
	-- how many points do customer A and B have at the end of January?


-- Running [dbo].[sales] 
-- Answering Question one
-- What is the total amount each customer spent at the restaurant?

-- Selecting sales DB
SELECT customer_id, sum(price) as Amount_spent
FROM sales s

-- Joining sales and menu db togther 
Full join menu m
on s.product_id = m.product_id

Group by customer_id
-- Amount spent by each customers are 76, 74 and 36 dollars for customer A, B and C respectively 


-- Running [dbo].[sales] 
-- Answering Question two
-- How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(order_date) as Noofdaysvisited
FROM sales

GROUP BY customer_id

-- Number of days each customer visited the restaurant are 6, 6, and 3 days for customer A, B and C respectively 
 
 SELECT * 
 FROM sales
-- Running [dbo].[sales] 
-- Answering Question three
-- What was the first item from the menu purchased by each customer?

-- CTE
WITH ranked AS (SELECT customer_id, product_name, order_date,
RANK () OVER (PARTITION BY customer_id order by order_date) as purchased_order
FROM sales s 

join menu m
on s.product_id = m.product_id
)

SELECT * from ranked 
where purchased_order = 1


-- Running [dbo].[sales] 
-- Answering Question four
-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT  s.product_id, product_name, count(product_name) as most_purchased_item
FROM sales s

Inner Join menu m
on s.product_id = m. product_id

group by product_name, 
		s.product_id

order by most_purchased_item DESC

-- and how many times was it purchased by all customers?
SELECT  customer_id, product_name, count(product_name) as number_of_times_purchased
FROM sales s
Inner Join menu m
on s.product_id = m. product_id

where product_name like '%ramen'
group by product_name, 
		s.customer_id

order by number_of_times_purchased DESC

-- Most Purchased item by all customer is ramen. It was purchased 8 times 


-- Running [dbo].[sales] 
-- Answering Question five
-- Which item was the most popular for each customer?

WITH ranked_customter AS (
SELECT s.Customer_id, count(s.product_id) as product_count, product_name, 
RANK () OVER (PARTITION  BY customer_id order by COUNT(S.product_id) desc) as customer_item
FROM sales s

Inner Join menu m
on s.product_id = m.product_id

GROUP BY S.product_id, customer_id, product_name)

SELECT * FROM ranked_customter
WHERE customer_item = 1


-- Running [dbo].[sales] 
-- Answering Question six
-- Which item was purchased first by the customer after they became a member?
SELECT s.customer_id, order_date, join_date, s.product_id, product_name  
FROM sales s 

inner join members me
on s.customer_id = me.customer_id

inner join menu m
on s.product_id = m.product_id

where order_date ='2021-01-07' and s.customer_id = 'A'
OR order_date = '2021-01-11' and s.customer_id = 'B'

ORDER BY customer_id 


-- Running [dbo].[members] 
-- Answering Question seven
-- Which item was purchased just before the customer became a member?
SELECT me.customer_id, order_date, s.product_id, m.product_name, 
case when order_date = '2021-01-01' and s.customer_id = 'A' then 'First order before membership for customer A' 
	when order_date = '2021-01-04' and s.customer_id = 'B'  then 'First order before membership for customer B'
	else 'Older Order' end as 'Membership_order'
FROM members me

inner join sales s
on me.customer_id = s.customer_id

inner join menu m
on s.product_id = m.product_id

where order_date < '2021-01-07'

-- Running [dbo].[sales] 
-- Answering Question eight
-- What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, sum(price) As amountspentbeforemembership, count(order_date) As totalitems
FROM sales s   

inner join menu m
on s.product_id = m.product_id 

inner join members me
on s.customer_id = me.customer_id

where order_date   < '2021-01-07'

GROUP BY S.customer_id


-- Running [dbo].[sales] 
-- Answering Question nine
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
	-- how many points would each customer have?

SELECT s.customer_id, 
sum(
case when s.product_id = 1 and price = 10 then price * 10
	 when s.product_id = 2 and price = 15 then price * 20
	 when s.product_id = 3 and price = 12 then price * 10
	 else 'no points' end) as Pointsearn
FROM sales s

full join menu m
on s.product_id = m.product_id

GROUP BY  s.customer_id


-- Running [dbo].[sales] 
-- Answering Question ten
-- In the first week after a customer joins the program (including their join date) 
	-- they earn 2x points on all items, not just sushi - 
	-- how many points do customer A and B have at the end of January?
SELECT s.customer_id, 
sum(
case when s.customer_id = 'A' or s.customer_id = 'B' then  price  * 20
	else price * 1 end) as Memberpoints
FROM sales s

inner join menu m
on s.product_id = m.product_id 

inner join members me
on s.customer_id = me.customer_id

where order_date < '2021-01-31'
group by s.customer_id

-- Membership Table 
-- N for NO while Y for YES
SELECT s.customer_id, order_date, product_name, price,
case when order_date >= join_date then  'Y'
	else 'N' end as Member
FROM sales s

inner join menu m
on s.product_id = m.product_id 

full join members me
on s.customer_id = me.customer_id

WITH membership_table_ranking as
(
SELECT s.customer_id, order_date, product_name, price,
case when order_date >= join_date then  'Y'
	else 'N' end as Member
FROM sales s 

inner join menu m
on s.product_id = m.product_id 

full join members me
on s.customer_id = me.customer_id
) 

SELECT *, 
CASE WHEN Member = 'N' THEN NULL
	 WHEN MEMBER = 'Y' THEN RANK () OVER (PARTITION BY customer_id, Member order by order_date)
	 else 0 end  as Member_ranking 
FROM  membership_table_ranking 




