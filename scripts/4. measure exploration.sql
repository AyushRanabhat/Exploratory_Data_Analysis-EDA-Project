-- ==============================================
-- MEASURES EXPLORATION
-- ==============================================
-- Analyze key business metrics: sales, quantity, products, orders, and customers.

-------------------------------------------------------------
-- 1. Total Sales
-------------------------------------------------------------
SELECT SUM(sales) AS total_sales
FROM gold.fact_sales;

-------------------------------------------------------------
-- 2. Total Quantity Sold
-------------------------------------------------------------
SELECT SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-------------------------------------------------------------
-- 3. Average Selling Price
-------------------------------------------------------------
SELECT AVG(price) AS average_price
FROM gold.fact_sales;

-------------------------------------------------------------
-- 4. Total Number of Orders
-------------------------------------------------------------
-- Total orders including duplicates
SELECT COUNT(order_number) AS total_orders
FROM gold.fact_sales;

-- Total distinct orders
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-------------------------------------------------------------
-- 5. Total Number of Products
-------------------------------------------------------------
SELECT COUNT(product_name) AS total_product FROM gold.dim_products;
SELECT COUNT(DISTINCT product_name) AS total_product FROM gold.dim_products;
SELECT COUNT(product_key) AS total_product FROM gold.dim_products;
SELECT COUNT(DISTINCT product_key) AS total_product FROM gold.dim_products;

-------------------------------------------------------------
-- 6. Total Number of Customers
-------------------------------------------------------------
SELECT COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

-------------------------------------------------------------
-- 7. Total Number of Customers Who Placed Orders
-------------------------------------------------------------
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales;

-------------------------------------------------------------
-- 8. Key Business Metrics Summary
-------------------------------------------------------------
SELECT 'Total Sales' AS measure_name, SUM(sales) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Items' AS measure_name, SUM(quantity) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' AS measure_name, AVG(price) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' AS measure_name, COUNT(DISTINCT product_name) AS measure_value
FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS measure_name, COUNT(customer_key) AS measure_value
FROM gold.dim_customers
UNION ALL
SELECT 'Customers with Orders' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value
FROM gold.fact_sales;
