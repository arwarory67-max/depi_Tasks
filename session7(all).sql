/* 1*/
create nonclustered index idx_cust_email 
on sales.customers(email)
go

/* 2*/
create nonclustered index idx_prod_cat_brand 
on production.products(category_id, brand_id)
go

/* 3*/
create nonclustered index idx_order_reporting 
on sales.orders(order_date) 
include (customer_id, store_id, order_status)
go

/* 4*/
create trigger trg_new_customer 
on sales.customers 
after insert
as
begin
    insert into sales.customer_log(customer_id, action)
    select customer_id, 'Welcome New Customer' 
    from inserted
end
go

/* 5*/
create trigger trg_track_price 
on production.products 
after update
as
begin
    if update(list_price)
    begin
        insert into production.price_history(product_id, old_price, new_price, changed_by)
        select i.product_id, d.list_price, i.list_price, 'System User'
        from inserted i
        join deleted d on i.product_id = d.product_id
    end
end
go

/* 6*/
create trigger trg_prevent_cat_del 
on production.categories 
instead of delete
as
begin
    if exists(select * from production.products p join deleted d on p.category_id = d.category_id)
    begin
        print 'Error: Cannot delete category because it has products.'
    end
    else
    begin
        delete from production.categories 
        where category_id in (select category_id from deleted)
    end
end
go

/* 7*/
create trigger trg_update_stock 
on sales.order_items 
after insert
as
begin
    update s
    set quantity = s.quantity - i.quantity
    from production.stocks s
    join inserted i on s.product_id = i.product_id
    join sales.orders o on i.order_id = o.order_id
    where s.store_id = o.store_id
end
go

/* 8*/
create trigger trg_audit_new_order 
on sales.orders 
after insert
as
begin
    insert into sales.order_audit(order_id, customer_id, store_id, staff_id, order_date)
    select order_id, customer_id, store_id, staff_id, order_date
    from inserted
end
go
