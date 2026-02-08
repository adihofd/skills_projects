-- Customer Segmentation by Geographic Region (India Market)

select customer_name,country
from customers
where country='India';

-- Customer Base Metric: Total Customer Count

select count(*) as customer_count
from customers;

-- High-Value Order Segment (Amount Threshold: 400+)

SELECT *
FROM orders
WHERE order_amount > 400;


-- Revenue Metric Calculation: Total Company Revenue

select sum(order_amount) as total_revenue
from orders;

-- Customer Revenue Analysis: Total Lifetime Value per Customer

select c.customer_id,customer_name,sum(o.order_amount) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_id;

-- Customer Transaction History: Order-Level Details with Timeline

select c.customer_id,o.order_date,o.order_amount
from customers c
join orders o
on c.customer_id=o.customer_id;

-- Geographic Revenue Analysis: Revenue Aggregation by Country

select c.country,sum(o.order_amount) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.country;

-- Top Customer Identification: Highest Revenue Customer (Top 1)

select c.customer_id,customer_name,sum(o.order_amount) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_id
order by total_revenue DESC
LIMIT 1;

-- Customer Segmentation: Top 3 Revenue-Generating Customers

select c.customer_id,customer_name,sum(o.order_amount) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_id,customer_name
order by total_revenue DESC
LIMIT 3;

-- Time-Series Analysis: Monthly Revenue Trend

select date_trunc('month',order_date) as month ,sum(order_amount) as total_revenue
from orders
group by date_trunc('month',order_date)
order by month;

-- Time-Series Analysis: Monthly Order Volume Metric

select date_trunc('month',order_date) as month,count(order_id) as no_of_orders
from orders
group by date_trunc('month',order_date)
order by month;

-- Customer Segmentation: Repeat Customers (Order Count > 1)

select customer_id,count(order_id) as no_of_orders
from orders
group by customer_id
having count(order_id) > 1
order by customer_id; 

-- Customer Analytics: Average Order Value (AOV) by Customer

select customer_id,avg(order_amount) as avg_amount
from orders
group by customer_id
order by customer_id; 

-- Geographic Segmentation: Top 3 Revenue Markets

select c.country,sum(o.order_amount) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.country
order by total_revenue DESC
LIMIT 3;

-- Geographic Market Analysis: Customer Count and Revenue by Country

select c.country,count(distinct c.customer_id) as no_of_customers,sum(o.order_amount) as total_revenue
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.country;

-- Window Analytics: Customer Revenue Ranking (Direct Aggregation Pattern)

select 
c.customer_id,
c.customer_name,
sum(o.order_amount) as total_revenue,
rank() over (order by sum(o.order_amount) desc)
from 
customers c
join
orders o
on 
c.customer_id=o.customer_id
group by 
c.customer_id,
c.customer_name;

-- Window Analytics: Customer Revenue Ranking (CTE Production Pattern)

with customer_rev as(
select 
c.customer_id,
c.customer_name,
sum(o.order_amount) as total_revenue
from customers c
join
orders o
on 
c.customer_id=o.customer_id
group by 
c.customer_id,
c.customer_name)

select 
customer_id,
customer_name,
total_revenue,
rank() over (order by total_revenue desc) as rev_rank
from customer_rev;


-- Customer Cohort Analysis: Lifecycle Metrics (First/Last Order, Volume)

with customer_summary as(
select 
c.customer_id,
c.customer_name,
min(o.order_date) as first_order_date,
max(o.order_date) as last_order_date,
count(o.order_id) as total_number_of_orders
from customers c
join orders o
on 
c.customer_id=o.customer_id
group by 
c.customer_id,
c.customer_name
order by
c.customer_id
)

select 
customer_id,
customer_name,
first_order_date,
last_order_date,
total_number_of_orders
from customer_summary;

-- Customer Segmentation: Inactive Customers (Anti-Join Pattern)

select c.customer_id,c.customer_name
from customers c
inner join orders o
on c.customer_id=o.customer_id
where o.customer_id is null;

-- Time-Series Analysis: Month-over-Month Revenue Comparison (LAG Window)

with month_rev as(
select date_trunc('month',order_date) as _month_,
sum(order_amount) as cur_mon_rev
from orders
group by _month_
)

select _month_,cur_mon_rev,
lag(cur_mon_rev) over(order by _month_) as prev_mon_rev,
(cur_mon_rev-(lag(cur_mon_rev) over(order by _month_))) as rev_diff
from month_rev
order by _month_;


-- Window Analytics: Customer Revenue Ranking by Geographic Region (Partition Window)

with customer_rev_rank as(
select 
c.customer_id,c.country,
sum(o.order_amount) as customer_revenue
from orders o
join customers c
on c.customer_id=o.customer_id
group by c.customer_id,c.country)

select customer_id,
customer_revenue,
country,
rank() over (
partition by country 
order by customer_revenue desc
) as cust_rev_rank
from customer_rev_rank;

-- Cumulative Metrics: Year-to-Date Revenue Running Total (Window SUM)

with mon_rev_run as(
select date_trunc('month',order_date) as month_,
sum(order_amount) as revenue
from orders
group by month_)

select 
month_,
revenue,
sum(revenue) over(order by month_) as run_rev
from 
mon_rev_run;

-- Revenue Analysis: Geographic Market Share Percentage (Window Total) 

with country_revenue_percentage as(
select c.country,
sum(order_amount) as revenue
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.country
)

select country,revenue,
(revenue/(sum(revenue) over()))*100 as per
from country_revenue_percentage
order by revenue desc;

-- Customer Segmentation: Above-Average Spending Cohort Analysis
with customer_avg_vs_total as(
select 
c.customer_id,
c.customer_name,
sum(o.order_amount) as total_spending
from 
customers c
join 
orders o
on 
c.customer_id=o.customer_id
group by 
c.customer_id,c.customer_name
)

select customer_id,customer_name,total_spending
from(
select *,avg(total_spending) over() as avg_spending
from customer_avg_vs_total
)cat
where total_spending>avg_spending;

-- Cumulative Metrics: Customer Lifetime Spending Timeline (Partition Window)

with csr as (select c.customer_id,o.order_date,o.order_amount
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_id,o.order_date,o.order_amount)

select customer_id,
order_date,
sum(order_amount) over(partition by customer_id order by order_date)
from csr;


