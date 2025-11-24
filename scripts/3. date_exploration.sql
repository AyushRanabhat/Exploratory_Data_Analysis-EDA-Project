-- ==============================================
-- DATE EXPLORATION
-- ==============================================
-- Analyze key dates and compute gaps or ages for orders, shipping, due dates, and customers.

-------------------------------------------------------------
-- 1. First and Last Order Date with Gaps
-------------------------------------------------------------
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS latest_order_date,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS gap_in_year,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS gap_in_month,
    DATEDIFF(DAY, MIN(order_date), MAX(order_date)) AS gap_in_day
FROM gold.fact_sales;

-------------------------------------------------------------
-- 2. First and Last Shipping Date with Gaps
-------------------------------------------------------------
SELECT 
    MIN(shipping_date) AS first_shipping_date,
    MAX(shipping_date) AS latest_shipping_date,
    DATEDIFF(YEAR, MIN(shipping_date), MAX(shipping_date)) AS gap_in_year,
    DATEDIFF(MONTH, MIN(shipping_date), MAX(shipping_date)) AS gap_in_month,
    DATEDIFF(DAY, MIN(shipping_date), MAX(shipping_date)) AS gap_in_day
FROM gold.fact_sales;

-------------------------------------------------------------
-- 3. First and Last Due Date with Gaps
-------------------------------------------------------------
SELECT 
    MIN(due_date) AS first_due_date,
    MAX(due_date) AS latest_due_date,
    DATEDIFF(YEAR, MIN(due_date), MAX(due_date)) AS gap_in_year,
    DATEDIFF(MONTH, MIN(due_date), MAX(due_date)) AS gap_in_month,
    DATEDIFF(DAY, MIN(due_date), MAX(due_date)) AS gap_in_day
FROM gold.fact_sales;

-------------------------------------------------------------
-- 4. Youngest and Oldest Customer with Age
-------------------------------------------------------------
SELECT 
    MIN(birth_date) AS oldest_customer,
    MAX(birth_date) AS youngest_customer,
    DATEDIFF(YEAR, MIN(birth_date), GETDATE()) AS oldest_customer_age,
    DATEDIFF(YEAR, MAX(birth_date), GETDATE()) AS youngest_customer_age
FROM gold.dim_customers;
