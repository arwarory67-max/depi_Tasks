/* 1 */ 
select count(*) from production.products

/* 2 */ 
select avg(list_price), min(list_price), max(list_price) from production.products

/* 3 */ 
select c.category_name, count(*) 
from production.categories c 
join production.products p on c.category_id = p.category_id 
group by c.category_name

/* 4 */ 
select s.store_name, count(*) 
from sales.stores s 
join sales.orders o on s.store_id = o.store_id 
group by s.store_name

/* 5 */ 
select top 10 upper(first_name), lower(last_name) from sales.customers

/* 6 */ 
select top 10 product_name, len(product_name) from production.products

/* 7 */ 
select top 15 left(phone, 3) from sales.customers

/* 8 */ 
select top 10 getdate(), year(order_date), month(order_date) from sales.orders

/* 9 */ 
select top 10 p.product_name, c.category_name 
from production.products p 
join production.categories c on p.category_id = c.category_id

/* 10 */ 
select top 10 c.first_name, c.last_name, o.order_date 
from sales.customers c 
join sales.orders o on c.customer_id = o.customer_id

/* 11 */ 
select p.product_name, isnull(b.brand_name, 'No Brand') 
from production.products p 
left join production.brands b on p.brand_id = b.brand_id

/* 12 */ 
select product_name, list_price 
from production.products 
where list_price > (select avg(list_price) from production.products)

/* 13 */ 
select customer_id, first_name, last_name 
from sales.customers 
where customer_id in (select customer_id from sales.orders)

/* 14 */ 
select first_name, last_name, 
(select count(*) from sales.orders o where o.customer_id = c.customer_id) as total_orders 
from sales.customers c

/* 15 */ 
create view easy_product_list as 
select p.product_name, c.category_name, p.list_price 
from production.products p 
join production.categories c on p.category_id = c.category_id;

select * from easy_product_list where list_price > 100

/* 16 */ 
create view customer_info as 
select customer_id, first_name + ' ' + last_name as full_name, email, city + ', ' + state as location 
from sales.customers;

select * from customer_info where location like '%CA'

/* 17 */ 
select product_name, list_price 
from production.products 
where list_price between 50 and 200 
order by list_price asc

/* 18 */ 
select state, count(*) as count 
from sales.customers 
group by state 
order by count desc

/* 19 */ 
select c.category_name, p.product_name, p.list_price 
from production.products p 
join production.categories c on p.category_id = c.category_id 
where p.list_price = (select max(list_price) from production.products where category_id = p.category_id)

/* 20 */ 
select s.store_name, s.city, count(o.order_id) 
from sales.stores s 
left join sales.orders o on s.store_id = o.store_id 
group by s.store_name, s.city
