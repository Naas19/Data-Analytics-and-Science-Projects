select * from campaign;
select * from city;
select * from couponmapping;
select * from customer;
select * from customertransactiondata;
select * from item;



-- section 1
-- q1 Different color segments (categories) provided by the company.

select distinct(Item_Category) 
from item;


-- q2
-- Different Coupon Types that are offered.
select distinct(couponType) as aa, count(couponType) as cardinality
from couponmapping
group by aa;

-- q3 States where the company is currently delivering its products and services.
 select distinct(state) as bb,count(state) as cardinality
 from city
 group by bb;
 
 -- q4 Different Order Types.
 select distinct(OrderType) as zz, COUNT(OrderType) as cardinality
from customertransactiondata
group by zz;

-- Q3 a1  Identify total number of sales (transactions) happened by Yearly basis
select * from customertransactiondata;
select count(Trans_Id) as no_of_sales, extract(YEAR FROM PurchaseDate) as yrr
from customertransactiondata
group by yrr
order by yrr asc;

-- qb Quarterly basis
select count(Trans_Id) as no_of_sales, extract(quarter FROM PurchaseDate) as quarter_1
from customertransactiondata
group by quarter_1
order by no_of_sales desc;

-- QC Yearly and Monthly basis
select count(Trans_Id) as no_of_sales, extract(YEAR from PurchaseDate) as year_1, extract(month from PurchaseDate) as month_1
from customertransactiondata
group by month_1,year_1
order by year_1 asc, month_1 asc;


-- Q4. Identify the total purchase order by Product category
select  distinct(item_category) as prduct_cat, sum(ta.quantity) as quantity, ROUND(sum(ta.PurchasingAmt),2) as amt_1
from customertransactiondata as ta
inner join item as tt
on ta.item_id = tt.Item_Id
group by prduct_cat;

-- Yearly and Quarterly basis

SELECT
  SUM(quantity) AS total_quantity,
  ROUND(SUM(PurchasingAmt), 2) AS total_amount,
  EXTRACT(YEAR FROM PurchaseDate) AS year,
  QUARTER(PurchaseDate) AS quarter
FROM customertransactiondata
GROUP BY year, quarter
ORDER BY year ASC, quarter ASC;


-- Order Type
select sum(quantity) as total_quantity, round(sum(PurchasingAmt),2) as total_amount, OrderType
from customertransactiondata
group by OrderType;

-- City Tier
select sum(quantity) as total_quantity, round(sum(PurchasingAmt),2) as total_amount, ci.CityTier
from customertransactiondata as ca
inner join customer as cu
inner join city as ci
on cu.City_Id = ci.City_Id
group by ci.CityTier
order by ci.CityTier asc;


-- Section 2 Identify the total number of transactions with campaign coupon vs total number of transactions without campaign coupon.
SELECT
  COUNT(CASE WHEN campaign_id IS NULL THEN Trans_Id END) AS with_campaign_coupon,
  COUNT(CASE WHEN campaign_id IS NOT NULL THEN Trans_Id END) AS without_campaign_coupon
FROM customertransactiondata;


-- Identify the number of customers with first purchase done with or without campaign coupons.
select * from customertransactiondata;

WITH FirstPurchase AS (
  SELECT
    Cust_Id,
    MIN(PurchaseDate) AS first_purchase_date
  FROM customertransactiondata
  GROUP BY Cust_Id
)

SELECT
  COUNT(CASE WHEN cd.coupon_id IS NULL THEN fp.Cust_Id END) AS count_without_coupons,
  COUNT(CASE WHEN cd.coupon_id IS NOT NULL THEN fp.Cust_Id END) AS count_with_coupons
FROM FirstPurchase as fp
LEFT JOIN customertransactiondata as cd
ON fp.Cust_Id = cd.Cust_Id AND fp.first_purchase_date = cd.PurchaseDate;


-- Identify the impact of campaigns on users. Check the total number of unique users making purchases with or without campaign coupons.
SELECT 
  COUNT(DISTINCT CASE WHEN coupon_id IS NULL THEN Cust_Id END) AS without_coupons,
  COUNT(DISTINCT CASE WHEN coupon_id IS NOT NULL THEN Cust_Id END) AS with_coupons
FROM customertransactiondata;

-- Check the purchase amount with campaign coupons vs normal coupons vs no coupons.
SELECT 
  SUM(CASE WHEN campaign_id IS NOT NULL THEN PurchasingAmt END) AS with_campaign_coupons,
  SUM(CASE WHEN coupon_id IS NOT NULL AND campaign_id is null then  PurchasingAmt END) AS with_normal_coupons,
  SUM(CASE WHEN coupon_id IS  NULL THEN PurchasingAmt END) AS no_coupons
FROM customertransactiondata;

-- from the above results we understand that the purchasing amount has increased with the use of campaign coupns.alter

-- Section 3 1. Identify the total growth on an year by year basis excluding the current year.   1. Based on quantity of paint that is sold
select sum(quantity), extract(year from PurchaseDate) as yrr
from customertransactiondata
WHERE PurchaseDate NOT between '2023-01-01' and '2023-12-31'
group by yrr
order by yrr asc;


-- Based on amount of paint that is sold
select ROUND(sum(PurchasingAmt),2) as purchase_amount, extract(year from PurchaseDate) as yrr
from customertransactiondata
WHERE PurchaseDate NOT between '2023-01-01' and '2023-12-31'
group by yrr
order by yrr asc;


-- . Based on new customers that are acquired. (Hint: Get distinct new users every year before year by year analysis).


WITH YearlySummary AS (
  SELECT
    EXTRACT(YEAR FROM PurchaseDate) AS yearr,
    SUM(quantity) AS total_quantity_of_paint,
    ROUND(SUM(PurchasingAmt), 2) AS total_purchasing_amt,
    COUNT(DISTINCT cust_id) AS total_customers,
    MIN(PurchaseDate) AS min_purchase_date
  FROM
    customertransactiondata
  WHERE
    PurchaseDate NOT BETWEEN '2023-01-01' AND '2023-12-31'
  GROUP BY
    yearr
)
SELECT * FROM YearlySummary ORDER BY yearr ASC;


--  Segregate them By OrderType (Note: This is a new question, sub-part of 1c)
SELECT
    EXTRACT(YEAR FROM PurchaseDate) AS yrr,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(PurchasingAmt), 2) AS total_purchasing_amt,
    COUNT(DISTINCT cust_id) AS total_customers,
    MIN(PurchaseDate) AS min_purchase_date, OrderType
from customertransactiondata
WHERE
    PurchaseDate NOT BETWEEN '2023-01-01' AND '2023-12-31'
group by yrr,OrderType;

-- section 4 Please identify the dates when the same customer has purchased some product from the company outlets. Transactions from same order types and different products are only valid transactions here.

SELECT c2.cust_id, c2.Trans_Id,c2.item_id, c2.PurchaseDate, c2.OrderType
FROM customertransactiondata AS c1
INNER JOIN customertransactiondata AS c2 
ON c1.Cust_Id = c2.Cust_Id
WHERE c1.OrderType = c2.OrderType 
  AND c1.Trans_Id <> c2.Trans_Id 
  AND c1.PurchaseDate = c2.PurchaseDate
ORDER BY c2.Cust_Id, c2.PurchaseDate;

select * from customertransactiondata;

-- Out of the above, please identify the same combination of products coming at least thrice sorted in descending order of their appearance. 

SELECT c2.cust_id, c2.Trans_Id,c2.item_id, c2.PurchaseDate, c2.OrderType
FROM customertransactiondata AS c1
INNER JOIN customertransactiondata AS c2 
ON c1.Cust_Id = c2.Cust_Id
WHERE c1.OrderType = c2.OrderType 
  AND c1.Trans_Id <> c2.Trans_Id 
  AND c1.PurchaseDate = c2.PurchaseDate
   ORDER BY c2.Cust_Id asc, c2.PurchaseDate asc;

--  FOLLOWING A PATTERN FROM THE ABOVE QUERY item 13,16 WAS A COMBINATION occurring 8 times ,

SELECT c2.cust_id, c2.Trans_Id,c2.item_id, c2.PurchaseDate, c2.OrderType
FROM customertransactiondata AS c1
INNER JOIN customertransactiondata AS c2 
ON c1.Cust_Id = c2.Cust_Id
WHERE c1.OrderType = c2.OrderType 
  AND c1.Trans_Id <> c2.Trans_Id 
  AND c1.PurchaseDate = c2.PurchaseDate
  AND c2.item_id in ('Item_13','Item_16')
ORDER BY c2.Cust_Id desc, c2.PurchaseDate desc;


-- Out of the above combinations (coming thrice), please check which of these combinations are popular in different sectors (household, industrial and government).
with productcombo as (
SELECT c2.cust_id, c2.Trans_Id,c2.item_id, c2.PurchaseDate, c2.OrderType
FROM customertransactiondata AS c1
INNER JOIN customertransactiondata AS c2 
ON c1.Cust_Id = c2.Cust_Id
WHERE c1.OrderType = c2.OrderType 
  AND c1.Trans_Id <> c2.Trans_Id 
  AND c1.PurchaseDate = c2.PurchaseDate
  AND c2.item_id in ('Item_13','Item_16')
ORDER BY c2.Cust_Id desc, c2.PurchaseDate desc)
select count(Ordertype), OrderType
from productcombo
group by OrderType;

-- combination of products bought were item_13(navy blue) and item_16(white) 

-- item_14,35,61 and 4 can be promoted as the combination of these items were bought by customer (C_63) on the same day

-- section 5 1. Create Functions for the following:  Get the total discount, if any. 

select * from couponmapping;
DELIMITER $$
CREATE FUNCTION get_total_discount(Item_id_input VARCHAR(10))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE coupon_info VARCHAR(255);
    SELECT CONCAT(couponType, ' ', Value_Amt) INTO coupon_info
  FROM couponmapping
  WHERE Item_id = Item_id_input;
  

  -- If the Item_id is not found
  IF coupon_info IS NULL THEN
    SET coupon_info = 'No discount information found';
  END IF;

  RETURN coupon_info;
END $$
DELIMITER ;
select  get_total_discount('Item_55') as total_discount;

-- Get the days/month/year elapsed since the last purchase of a customer depending on input from user. [Hint: Use If condition within the function]

DELIMITER $$
CREATE FUNCTION days_elapsed_2(cust_id_input VARCHAR(10))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
  DECLARE days_diff VARCHAR(50);

  SELECT CONCAT(
    TIMESTAMPDIFF(YEAR, max(PurchaseDate), NOW()), ' years, ',
    TIMESTAMPDIFF(MONTH, Max(PurchaseDate), NOW()) , ' months, ',
    TIMESTAMPDIFF(DAY, Max(PurchaseDate), NOW()) , ' days'
  ) INTO days_diff
  FROM customertransactiondata
  WHERE cust_id = cust_id_input;

  RETURN days_diff;
END $$
DELIMITER ;

select days_elapsed_2('C_48') as date_diff;



 
 
DELIMITER $$
CREATE FUNCTION get_total_discount_old(Item_id_input VARCHAR(10))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE coupon_info VARCHAR(255);
    SELECT CONCAT(couponType, ' ', Value_Amt), (PurchasingAmt - Value_Amt)  as subtract_discount INTO coupon_info
  FROM couponmapping as cpa
  inner join customertransactiondata as csa
  on cpa.item_id = csa.item_id
  WHERE csa.item_id = Item_id_input;
  

  -- If the Item_id is not found
  IF coupon_info IS NULL THEN
    SET coupon_info = 'No discount information found';
  END IF;

  RETURN coupon_info;
END $$
DELIMITER ;

select  get_total_discount_old('Item_55') as total_discount2;
 
 drop function get_total_discount2;
 
 
 
 
DELIMITER $$
CREATE FUNCTION get_total_discount2(Item_id_input VARCHAR(10))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE coupon_type_value VARCHAR(50);
  DECLARE discount_allowed_coupon DECIMAL(10, 2);
  DECLARE after_discount DECIMAL(10, 2);

  -- Retrieve discount information
  SELECT IFNULL(couponType, 'No Coupon'), IFNULL(Value_Amt, 0), IFNULL(PurchasingAmt - Value_Amt, 0)
  INTO coupon_type_value, discount_allowed_coupon, after_discount
  FROM couponmapping AS cpa
  INNER JOIN customertransactiondata AS csa ON cpa.item_id = csa.item_id
  WHERE csa.item_id = Item_id_input
  ORDER BY discount_allowed_coupon -- Add an appropriate column for ordering
  LIMIT 1;

  -- If the Item_id is not found
  IF coupon_type_value IS NULL THEN
    RETURN 'No discount information found';
  END IF;

  RETURN CONCAT(coupon_type_value, ' ', discount_allowed_coupon, ' ', after_discount);
END $$
DELIMITER ;

-- Call the function
SELECT get_total_discount2('Item_55') AS total_discount2;



-- Identify the top 10 customers along with their demographic details from each sector based on their total discount.
CREATE VIEW demographic_details_2 AS 
with table_1 as (
select Cust_Id, cts.item_id,cts.coupon_id,couponType,Value_Amt,Min_Purchase,PurchasingAmt
from customertransactiondata as cts
inner join couponmapping as cpa
on cts.coupon_id = cpa.coupon_id
WHERE cts.coupon_id  is not null
)
SELECT ca.Customer_Id,ca.Gender,ca.City_Id,Pincode,ca.Birthdate,ca.income_bracket,ca.emailId,ca.PhoneNo,
    CASE 
        WHEN couponType = 'Flat' THEN (PurchasingAmt - Value_Amt)
        WHEN couponType = 'Percent' THEN (PurchasingAmt - (PurchasingAmt * (Value_Amt / 100)))
    END AS discounted_amount
FROM table_1 as t1
inner join customer as ca 
on t1.Cust_id = ca.Customer_Id
order by discounted_amount desc 
limit 10;

select * from demographic_details_2;

-- Identify the top 5 customers (from household and industrial sector) based on purchase amount and days elapsed in descending order. Do highlight if you think there is a data error.

CREATE VIEW  TOP_5_CUSTS AS 
select cust_id,sum(purchasingamt) as p_amt,CONCAT(
    TIMESTAMPDIFF(YEAR, max(PurchaseDate), NOW()), ' years, ',
    TIMESTAMPDIFF(MONTH, Max(PurchaseDate), NOW()) , ' months, ',
    TIMESTAMPDIFF(DAY, Max(PurchaseDate), NOW()) , ' days')
    AS days_elapsed, OrderType
    from  customertransactiondata
    WHERE OrderType in ('Household','Industrial')
    group by cust_id,OrderType
    order by p_amt desc,days_elapsed desc
    limit 5;

select * from TOP_5_CUSTS;



-- Identify the top 10 products that are sold last year based on sales amount along with the last 2 year details of the same. 
SELECT * FROM ITEM;

create view top_10_prods_2022 as 
select  tta.item_Name, tta.item_id, sum(PurchasingAmt) as p_amt, CTS.PurchaseDate
 from customertransactiondata AS CTS
 inner join item as tta
 on CTS.item_id = tta.Item_Id
 WHERE CTS.PurchaseDate  between '2022-01-01'and '2022-12-31'
 group by tta.item_Name,tta.item_id,CTS.PurchaseDate
 order by p_amt DESC
 LIMIT 10;
select * from top_10_prods_2022;

create view top_10_prods_2021 as 
 select  tta.item_Name, tta.item_id, sum(PurchasingAmt) as p_amt, CTS.PurchaseDate
 from customertransactiondata AS CTS
 inner join item as tta
 on CTS.item_id = tta.Item_Id
 WHERE CTS.PurchaseDate  between '2021-01-01'and '2021-12-31'
 group by tta.item_Name,tta.item_id,CTS.PurchaseDate
 order by p_amt DESC
 LIMIT 10;
select * from top_10_prods_2021;

create view top_10_prods_2020 as 
select  tta.item_Name, tta.item_id, sum(PurchasingAmt) as p_amt, CTS.PurchaseDate
 from customertransactiondata AS CTS
 inner join item as tta
 on CTS.item_id = tta.Item_Id
 WHERE CTS.PurchaseDate  between '2020-01-01'and '2020-12-31'
 group by tta.item_Name,tta.item_id,CTS.PurchaseDate
 order by p_amt DESC
 LIMIT 10;

select * from top_10_prods_2020;


-- Create 3 different income groups for household sector people - ‘high class’, ‘low class’, ‘middle class’ - based on their percent rank (33% each) and identify the top 2 products that are bought within these income class.

select * from customer;

CREATE VIEW income_percent_rank_view AS
SELECT
  distinct(Customer_Id),
  Name,
  Gender,
  City_Id,
  Pincode,
  Birthdate,
  income_bracket,cta.OrderType,
  percent_rank() over (order by income_bracket) as diff_sector
FROM customer as ca
inner join customertransactiondata as cta
on ca.Customer_Id = cta.Cust_Id
WHERE cta.OrderType = 'Household';


-- Identify the income groups for household sector people
WITH IncomeGroups AS (
  SELECT
    Customer_Id,
    Name,
    Gender,
    City_Id,
    Pincode,
    Birthdate,
    income_bracket,
    CASE
      WHEN diff_sector <= 0.33 THEN 'low class'
      WHEN diff_sector <= 0.66 THEN 'middle class'
      ELSE 'high class'
    END AS income_group
  FROM income_percent_rank_view
)

-- Identify the top 2 products for each income class
SELECT
  ig.income_group,
  ctd.item_id,
  t.item_Name,
  SUM(ctd.PurchasingAmt) AS total_purchase_amount
FROM IncomeGroups ig
JOIN customertransactiondata ctd ON ig.Customer_Id = ctd.Cust_Id
JOIN item t ON ctd.item_id = t.item_id
GROUP BY 
  ig.income_group,
  ctd.item_id,
  t.item_Name
ORDER BY
  ig.income_group,
  total_purchase_amount DESC;
  
  
DELIMITER //

CREATE PROCEDURE check_cust_age() 
BEGIN
   WITH CUSTOMER_2 AS (
      SELECT Customer_Id, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM Birthdate) AS birthyear
      FROM customer
   )
   
   SELECT Customer_Id
   FROM CUSTOMER_2
   WHERE birthyear <= 12;
END //

DELIMITER ;

call check_cust_age();