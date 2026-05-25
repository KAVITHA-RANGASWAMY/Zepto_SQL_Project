use zepto_project_sql;

create table zepto(
category varchar(150),
name varchar(150) not null,
mrp varchar(100),
discountPercent integer,
availableQuantity integer,
discountedSellingPrice Numeric(8,2),
weightInGms Integer,
OutOfStock Boolean,
quantity Integer
);


set sql_safe_updates =0;

update zepto
set outofstock = case
when outofstock = '0'then 'false'
when outofstock = '1'then 'true'
end;

set sql_safe_updates =1;

alter table zepto
modify column outofstock varchar(10);

-- data exploration
select count(*) from zepto;

select * from zepto;

-- sample data
select * from zepto
limit 10;

-- altering the table zepto and adding id column as a primary key
alter table zepto
add id serial primary key first;

-- null values
select * from zepto 
where name is null
or
category is null
or
mrp is null
or
discountPercent is null
or
availableQuantity is null
or
discountedSellingPrice is null
or
weightInGms is null
or
outofstock is null
or
quantity is null;

-- different product category
select distinct category
from zepto
order by category;

-- product are in stock and outofstock
select outofstock, count(id)
from zepto
group by outofstock;

-- product name present multiple times
select name,count(id) as "number of id"
from zepto
group by name
having count(id)>1
order by count(id)desc;

-- data cleaning

-- products with price 0

select  * from zepto
where mrp=0 or discountedSellingPrice=0;

delete from zepto 
where mrp=0;

-- convert paise into rupees
update zepto
set mrp = mrp /100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

select mrp,discountedSellingPrice from zepto;

-- 1. Find the top 10 best-value product based on the discount percent.
Select distinct name, mrp, discountPercent
from zepto
order by discountPercent Desc
limit 10;

-- 2. what are the products with highest mrp but out of stock.
select distinct name, mrp
from zepto
where OutOfStock = "True" and mrp > 200
order by mrp desc;

-- 3. Calculate estimated revenue for each category.
select category,
SUM(discountedSellingPrice * availableQuantity) as total_revenue
from zepto
group by Category
order by total_revenue;

-- 4. Find all products where mrp is greater than 500 and discount Percent in less then 10%
select distinct name, discountPercent, mrp
from zepto
where mrp >500 and discountPercent <10
Order by mrp desc, discountPercent desc;

-- 5. Identity the top 5 categories offering the highest average discount percent.
select category,
round(avg (discountPercent),2) as avg_discount
from zepto
group by category
order by avg_discount desc
limit 5;

-- 6. Find the price per gram for products above 100g and sort_by best value.
select distinct name,weightInGms, discountedSellingPrice,
Round(discountedSellingPrice/weightInGms,2) as price_per_gram
from zepto
where weightInGms >= 100
order by price_per_gram;

-- 7. Group the products into categories like low, medium, bulk.
select Distinct name, weightInGms,
case when weightInGms < 1000 Then 'Low'
when weightInGms < 5000 Then 'Medium'
else "Bulk"
End as weight_category
from zepto;

-- 8. What is the Total Inventory Weight Per Category.
select category, 
sum(weightInGms * availableQuantity) as Total_weight
from zepto
Group by category
order by total_weight;

