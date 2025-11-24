-- ==============================================
-- DIMENSION EXPLORATION
-- ==============================================
-- Explore dimension tables to understand customers, products, categories, and their presence in fact tables.

-------------------------------------------------------------
-- 1. Explore all countries where customers come from
-------------------------------------------------------------
SELECT DISTINCT country
FROM gold.dim_customers;

-------------------------------------------------------------
-- 2. Explore all product categories and subcategories
-------------------------------------------------------------
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;

-------------------------------------------------------------
-- 3. Count distinct dimension members in the fact table
-------------------------------------------------------------
SELECT
    COUNT(DISTINCT customer_key) AS customers_in_sales,
    COUNT(DISTINCT product_key) AS products_in_sales
FROM gold.fact_sales;

-------------------------------------------------------------
-- 4. Customers not in sales (never placed an order)
-------------------------------------------------------------
SELECT *
FROM gold.dim_customers AS C
LEFT JOIN gold.fact_sales AS F
    ON C.customer_key = F.customer_key
WHERE F.customer_key IS NULL;

-------------------------------------------------------------
-- 5. Products not in sales by category
-------------------------------------------------------------
SELECT 
    COUNT(DISTINCT P.product_key) AS product_count,
    P.category
FROM gold.dim_products AS P
LEFT JOIN gold.fact_sales AS F
    ON P.product_key = F.product_key
WHERE F.product_key IS NULL
GROUP BY P.category
ORDER BY P.category;

-------------------------------------------------------------
-- 6. Customer demographics (example: gender distribution)
-------------------------------------------------------------
SELECT
    gender,
    COUNT(*) AS total
FROM gold.dim_customers
GROUP BY gender;

-------------------------------------------------------------
-- 7. Sales by product category
-------------------------------------------------------------
SELECT
    P.category,
    SUM(F.sales) AS total_sales
FROM gold.fact_sales AS F
JOIN gold.dim_products AS P
    ON F.product_key = P.product_key
GROUP BY P.category
ORDER BY total_sales DESC;

-------------------------------------------------------------
-- 8. Dimension change detection (SCD check)
-------------------------------------------------------------
-- Identify customers with multiple records (versions)
SELECT 
    customer_key,
    COUNT(*) AS versions
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
