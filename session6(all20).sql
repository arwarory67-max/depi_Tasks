use StoreDB
go

/*1*/
declare @custId int = 200
declare @total decimal(10, 2)
declare @msg varchar(100)

select @total = sum(quantity * list_price) 
from sales.order_items i 
join sales.orders o on i.order_id = o.order_id 
where o.customer_id = @custId

if @total > 5000
	set @msg = 'vip customer'
else
	set @msg = 'regular customer'

print @msg
go

/* 2*/
declare @price decimal(10, 2) = 1500
declare @count int

select @count = count(*) from production.products where list_price > @price

print 'Threshold: ' + cast(@price as varchar) + ' Count: ' + cast(@count as varchar)
go

/* 3 */
declare @staffId int = 6
declare @year int = 2023
declare @sales decimal(10, 2)

select @sales = sum(quantity * list_price)
from sales.orders o 
join sales.order_items i on o.order_id = i.order_id
where o.staff_id = @staffId and year(order_date) = @year

print 'Staff: ' + cast(@staffId as varchar) + ' Total: ' + cast(@sales as varchar)
go

/* 4. global variables */
select @@servername, @@version, @@rowcount
go

/* 5 */
declare @qty int
select @qty = quantity from production.stocks where product_id = 1 and store_id = 1

if @qty > 20
	print 'Well stocked'
else if @qty between 10 and 20
	print 'Moderate stock'
else
	print 'Low stock'
go

/* 6*/
while exists (select * from production.stocks where quantity < 5)
begin
	update top(3) production.stocks 
	set quantity = quantity + 10 
	where quantity < 5
	
	print 'updated batch of 3'
end
go

/* 7*/
select product_name, list_price,
case
	when list_price < 300 then 'Budget'
	when list_price between 300 and 800 then 'Mid-Range'
	when list_price between 801 and 2000 then 'Premium'
	else 'Luxury'
end as category
from production.products
go

/* 8*/
declare @id_check int = 5
if exists(select * from sales.customers where customer_id = @id_check)
begin
	select count(*) from sales.orders where customer_id = @id_check
end
else
begin
	print 'No Customer'
end
go

/* 9*/
create function CalculateShipping(@total decimal(10,2))
returns decimal(10,2)
as
begin
	declare @cost decimal(10,2)
	if @total > 100 set @cost = 0
	else if @total >= 50 set @cost = 5.99
	else set @cost = 12.99
	return @cost
end
go

/* 10*/
create function GetProductsByPriceRange(@min decimal, @max decimal)
returns table
as
return (
	select p.product_name, b.brand_name, c.category_name, p.list_price
	from production.products p
	left join production.brands b on p.brand_id = b.brand_id
	left join production.categories c on p.category_id = c.category_id
	where list_price between @min and @max
)
go

/* 11*/
create function GetCustomerYearlySummary(@cid int)
returns @t table (yr int, orders int, spent decimal(10,2), avg_val decimal(10,2))
as
begin
	insert into @t
	select year(order_date), count(distinct o.order_id), sum(quantity*list_price), avg(quantity*list_price)
	from sales.orders o 
	join sales.order_items i on o.order_id = i.order_id
	where o.customer_id = @cid
	group by year(order_date)
	return
end
go

/* 12*/
create function CalculateBulkDiscount(@qty int)
returns decimal(4,2)
as
begin
	if @qty <= 2 return 0
	if @qty <= 5 return 0.05
	if @qty <= 9 return 0.10
	return 0.15
end
go

/* 13*/
create proc sp_GetCustomerOrderHistory
@cid int, @start date = null, @end date = null
as
begin
	select * from sales.orders 
	where customer_id = @cid
	and (@start is null or order_date >= @start)
	and (@end is null or order_date <= @end)
end
go

/* 14*/
create proc sp_RestockProduct
@sid int, @pid int, @qty int, 
@old int output, @new int output, @success bit output
as
begin
	select @old = quantity from production.stocks where store_id = @sid and product_id = @pid
	if @old is not null
	begin
		update production.stocks set quantity = quantity + @qty where store_id = @sid and product_id = @pid
		set @new = @old + @qty
		set @success = 1
	end
	else
		set @success = 0
end
go

/* 15*/
create proc sp_ProcessNewOrder
@cid int, @pid int, @qty int, @sid int
as
begin
	begin try
		begin tran
			declare @oid int
			declare @price decimal(10,2)
			
			select @price = list_price from production.products where product_id = @pid

			insert into sales.orders(customer_id, order_status, order_date, required_date, store_id, staff_id)
			values(@cid, 1, getdate(), getdate()+7, @sid, 1)
			
			set @oid = @@identity
			
			insert into sales.order_items(order_id, item_id, product_id, quantity, list_price, discount)
			values(@oid, 1, @pid, @qty, @price, 0)
		commit tran
		print 'Done'
	end try
	begin catch
		rollback tran
		print 'Error happened'
	end catch
end
go

/* 16*/
create proc sp_SearchProducts
@name varchar(50) = null, @min decimal = null, @max decimal = null
as
begin
	declare @sql nvarchar(1000)
	set @sql = 'select * from production.products where 1=1 '
	
	if @name is not null
		set @sql = @sql + ' and product_name like ''%' + @name + '%'''
	
	if @min is not null
		set @sql = @sql + ' and list_price >= ' + cast(@min as varchar)
		
	if @max is not null
		set @sql = @sql + ' and list_price <= ' + cast(@max as varchar)
		
	exec(@sql)
end
go

/* 17*/
declare @start date = '2022-01-01'
declare @end date = '2022-03-31'

select s.first_name, sum(quantity * list_price) as total,
case
	when sum(quantity * list_price) > 50000 then '5%'
	when sum(quantity * list_price) > 20000 then '3%'
	else '0%'
end as bonus
from sales.staffs s
join sales.orders o on s.staff_id = o.staff_id
join sales.order_items i on o.order_id = i.order_id
where order_date between @start and @end
group by s.first_name
go

/* 18*/
declare @pid int = 10
declare @sid int = 1
declare @q int
declare @cat int

select @q = s.quantity, @cat = p.category_id 
from production.stocks s 
join production.products p on s.product_id = p.product_id
where s.store_id = @sid and s.product_id = @pid

if @q < 10
begin
	if @cat = 1 
		print 'Reorder 50'
	else
		print 'Reorder 20'
end
else
	print 'Stock ok'
go

/* 19*/
select customer_id, 
case 
	when sum(quantity*list_price) > 5000 then 'Gold'
	when sum(quantity*list_price) > 1000 then 'Silver'
	else 'Bronze'
end as tier
from sales.orders o 
join sales.order_items i on o.order_id = i.order_id
group by customer_id
go

/* 20*/
create proc sp_DiscontinueProduct
@pid int
as
begin
	if exists(select * from sales.order_items i join sales.orders o on i.order_id = o.order_id where product_id = @pid and order_status = 1)
	begin
		print 'Cannot delete, pending orders'
	end
	else
	begin
		delete from production.stocks where product_id = @pid
		print 'Inventory cleared'
	end
end
go
