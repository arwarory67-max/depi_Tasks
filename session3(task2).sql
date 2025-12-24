use storedb;
/*1*/select * from production.products 
where list_price >1000;

/*2*/select * from sales.customers 
where state in ('CA' , 'NY')

/*3*/select * from sales.orders 
where order_date between '2023-01-01' and '2023-12-31'

/*3*/select * from sales.orders 
where order_date >='2023-01-01'

/*4*/select * from sales.customers 
where email like ('%@gmail.com')

/*5*/select * from sales.staffs
where active =0

/*6*/ select top(5) * from production.products 
order by list_price desc

/*7*/ select top(10) * from sales.orders 
order by order_id asc

/*8*/ select top(3) * from sales.customers
order by last_name desc

/*9*/ select * from sales.customers
where phone is null

/*10*/ select * from sales.staffs
where manager_id is not null

/*11*/ select category_name, count(*) 
from production.categories c 
join production.products p on c.category_id = p.category_id 
group by category_name

/*12*/ select state, count(*) 
from sales.customers 
group by state

/*13*/select brand_name, avg(list_price) 
from production.brands b 
join production.products p on b.brand_id = p.brand_id 
group by brand_name

/*14*/select first_name, last_name, count(*) 
from sales.staffs s 
join sales.orders o on s.staff_id = o.staff_id 
group by first_name, last_name

/*15*/ select customer_id, count(*) 
from sales.orders 
group by customer_id 
having count(*) > 2

/*16*/select * from production.products 
where list_price between 500 and 1500

/*17*/select * from sales.customers 
where city like 'S%'

/*18*/select * from sales.orders 
where order_status in (2, 4)

/*19*/select * from production.products 
where category_id in (1, 2, 3)

/*20*/select * from sales.staffs 
where store_id = 1 or phone is null
