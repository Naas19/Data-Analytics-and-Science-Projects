select * from brands;
select * from categories;
select * from customers;
select * from order_items;
select * from orders;
select * from products;
select * from staffs;
select * from stocks;
select * from stores;

select s1.staff_id , s1.first_name , s1.last_name ,  s1.manager_id, s2.first_name, s2.staff_id
from staffs as s1
inner join staffs as s2
on s1.staff_id = s2.manager_id;

select s1.staff_id , s2.first_name  ,s1.first_name as manager_name  ,  s1.manager_id, s2.staff_id
from staffs as s1
inner join staffs as s2
on s1.staff_id = s2.manager_id;

# Names of staffs and their respective managers. 



select distinct(model_year)
from products;
# Model years of the bikes. 

with sale_tb1 as (select p1.product_id , p1.product_name, p1.model_year , (o1.list_price * o1.quantity) as sale_amount 
from products as p1
inner join order_items as o1 
on p1.product_id  = o1.product_id
group by p1.product_id , p1.product_name, p1.model_year, (o1.list_price * o1.quantity)
order by sale_amount DESC)
select *
from sale_tb1
where sale_amount > 2161 and model_year = 2018;

# list of products with sale amount greater than average 2018 bmodel.

with sale_tb1 as (select p1.product_id , p1.product_name, p1.model_year , (o1.list_price * o1.quantity) as sale_amount 
from products as p1
inner join order_items as o1 
on p1.product_id  = o1.product_id
group by p1.product_id , p1.product_name, p1.model_year, (o1.list_price * o1.quantity)
order by sale_amount DESC)
select *
from sale_tb1
where sale_amount < 2161 and model_year = 2018;

## list of products with sale amount less than average 2018 model.


select c1.customer_id , c1.first_name,c1.last_name , (o2.quantity *o2.list_price) as sale_amt
from customers as c1
inner join orders as o1 
on c1.customer_id = o1.customer_id
inner join order_items as o2 
on o1.order_id = o2.order_id
group by c1.customer_id , c1.first_name,c1.last_name , (o2.quantity *o2.list_price)
order by sale_amt DESC
LIMIT 50;

## TOP 50 CUSTOMERS WITH REGARD TO SALE AMOUNT.

select c1.customer_id , c1.first_name,c1.last_name , (o2.quantity *o2.list_price) as sale_amt
from customers as c1
inner join orders as o1 
on c1.customer_id = o1.customer_id
inner join order_items as o2 
on o1.order_id = o2.order_id
group by c1.customer_id , c1.first_name,c1.last_name , (o2.quantity *o2.list_price)
having sale_amt < 10599
order by sale_amt DESC
LIMIT 50;

# Next 50 customers with sale amount less than 10,500

select s1.store_id ,s2.store_name,s2.state, sum(s1.quantity) cycle_quantity
from stocks as s1
inner join stores as s2 
on s1.store_id = s2.store_id
group by s1.store_id ,s2.store_name,s2.state;

#Quantity of cycles stock available in respective stores and respective states. 



with sale_tb2 as (select c1.customer_id , c1.first_name,c1.last_name , (o2.quantity *o2.list_price) as sale_amt
from customers as c1
inner join orders as o1 
on c1.customer_id = o1.customer_id
inner join order_items as o2 
on o1.order_id = o2.order_id
group by c1.customer_id , c1.first_name,c1.last_name , (o2.quantity *o2.list_price)
order by sale_amt DESC)
select * , 
CASE 
WHEN sale_amt > 10599 then "Customer gets 30 percent off"
when sale_amt < 10599 and sale_amt > 7800 then "Customer gets 25 percent off"
when sale_amt <= 7800 then "Customer gets 15 percent off"
END as Customer_discount
from sale_tb2;

# Using case statements to determine loyal customers and providing discounts accordingly