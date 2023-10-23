-- dataset
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

Q.1 What is the total amount each customer spent on zomato?
select s.userid,sum(p.price) total_amt_spent
from sales s join product p 
on s.product_id = p.product_id
group by s.userid

Q.2 How many days has each customer visited zomato?
select userid,count(distinct created_date) days  
from sales
group by userid

Q.3 What was the first product purchased by each customer?
select * from 
(select *,rank() over(partition by userid order by created_date)
from sales) c
where rank = 1

Q.4 What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_id
from sales
group by product_id order by count(product_id) desc limit 1

select userid,count(product_id) cnt from sales where product_id = 
(select product_id from sales group by product_id order by count (product_id) desc limit 1)
group by userid

Q.5 Which item was the most popular for each customer?
select userid,product_id from
(select *,rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id,count(product_id) as cnt 
from sales group by userid, product_id)a)b
where rnk = 1

-- Difference between dates
SELECT DATE_PART('day', '2011-12-31'::timestamp - '2011-12-29'::timestamp);


Q.6 Which item was purchased first by the customer after they became a member?
select userid,product_id from
(select *,rank() over(partition by userid order by created_date) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date
from sales a join goldusers_signup b
on a.userid = b.userid
where a.created_date >= b.gold_signup_date)c)d
where rnk = 1

Q.7 Which item was purchased just before the customer became a member?
select userid,product_id from
(select *,rank() over(partition by userid order by created_date desc) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date
from sales a join goldusers_signup b
on a.userid = b.userid
where a.created_date <= b.gold_signup_date)c)d
where rnk = 1

Q.8 What is the total orders and amount spent for each member before they became a member?
select c.userid,
count(c.created_date) as total_orders,
sum(d.price) as amt_spent from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date
from sales a join goldusers_signup b
on a.userid = b.userid
where a.created_date <= b.gold_signup_date)c
join product d
on c.product_id = d.product_id
group by userid

Q.9 If buying each product generates points for eg 5rs=2 zometo point and each product has different purchasing points
for eg for p1 5rs = 1 zomato point , for p2 10rs = 5 zomato point and p3 5rs = 1 zomato point,
calculate points collected by each customers and for which product most points have been given till now.

select userid,sum(zomato_points) as total_points
from (select *,
case 
    when product_name = 'p1' then price/5
	when product_name = 'p2' then price/2
	when product_name = 'p3' then price/5
end as zomato_points
from (select a.userid, b.product_name, b.price	
from sales a join product b
on a.product_id = b.product_id)c)d
group by userid

select product_name,sum(zomato_points) as product_points
from (select *,
case 
    when product_name = 'p1' then price/5
	when product_name = 'p2' then price/2
	when product_name = 'p3' then price/5
end as zomato_points
from (select a.userid, b.product_name, b.price	
from sales a join product b
on a.product_id = b.product_id)c)d
group by product_name
order by product_points desc
limit 1

-- Q.10 In the first one year after a customer joins the gold program (including their join date) irrespective
-- of what the customer has purchased they earn 5 Zomato points for every 10 rs spent who earned more 1 or 3
-- and what was their points earnings in their first yr?



Q.11 rank all the transaction of the customers
select *, rank() over(partition by userid order by created_date ) rnk from sales

-- Q.12 rank all the transactions for each member whenever they are a zomato gold member, for every non gold member transction mark as na


