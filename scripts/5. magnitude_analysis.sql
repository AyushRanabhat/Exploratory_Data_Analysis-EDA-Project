-- MAGNITUDE ANALYSIS

---------------------------------------------------------
-- 1) TOTAL CUSTOMERS BY COUNTRY
---------------------------------------------------------
SELECT country,
       COUNT(customer_key) AS total_nr_customers
FROM gold.dim_customers 
GROUP BY country
ORDER BY total_nr_customers DESC;


---------------------------------------------------------
-- 2) TOTAL CUSTOMERS BY GENDER
---------------------------------------------------------
SELECT gender,
       COUNT(customer_key) AS total_nr_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_nr_customers DESC;


---------------------------------------------------------
-- 3) TOTAL PRODUCTS BY CATEGORY
---------------------------------------------------------
SELECT category,
       COUNT(DISTINCT product_key) AS total_product
FROM gold.dim_products
GROUP BY category
ORDER BY total_product DESC;


---------------------------------------------------------
-- 4) AVERAGE COST IN EACH CATEGORY
---------------------------------------------------------
SELECT category,
       AVG(cost) AS average_cost
FROM gold.dim_products
GROUP BY category
ORDER BY average_cost DESC;


---------------------------------------------------------
-- 5) TOTAL REVENUE BY CATEGORY
---------------------------------------------------------
SELECT p.category,
       SUM(f.sales) AS total_revenue
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS f
       ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;


---------------------------------------------------------
-- 6) TOTAL REVENUE BY CUSTOMER
---------------------------------------------------------
SELECT c.customer_key,
       c.first_name,
       c.last_name,
       SUM(f.sales) AS total_revenue
FROM gold.dim_customers AS c
LEFT JOIN gold.fact_sales AS f
       ON c.customer_key = f.customer_key
GROUP BY c.customer_key,
         c.first_name,
         c.last_name
ORDER BY total_revenue DESC;


---------------------------------------------------------
-- 7) DISTRIBUTION OF SOLD ITEMS ACROSS COUNTRIES
---------------------------------------------------------
SELECT c.country,
       SUM(f.quantity) AS total_sold_items
FROM gold.dim_customers AS c
LEFT JOIN gold.fact_sales AS f
       ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;


---------------------------------------------------------
-- 8) TOP 10 HIGHEST SELLING PRODUCTS
---------------------------------------------------------
SELECT TOP 10 p.product_name,
       SUM(f.sales) AS total_revenue
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS f
       ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

SELECT SUM(sales) FROM gold.fact_sales 


---------------------------------------------------------
-- 9) AVERAGE QUANTITY SOLD PER CATEGORY
---------------------------------------------------------
SELECT p.category,
       AVG(f.quantity) AS avg_quantity_sold
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS f
       ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY avg_quantity_sold DESC;


---------------------------------------------------------
-- 10) MONTHLY REVENUE TREND
---------------------------------------------------------
SELECT DATETRUNC(MONTH, order_date) AS sale_month,
       SUM(sales) AS total_revenue
FROM gold.fact_sales
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY sale_month;


---------------------------------------------------------
-- 11) CUSTOMER LIFETIME VALUE
---------------------------------------------------------
SELECT customer_key,
       SUM(sales) AS lifetime_value
FROM gold.fact_sales
GROUP BY customer_key
ORDER BY lifetime_value DESC;


---------------------------------------------------------
-- 12) AVERAGE ORDER VALUE
---------------------------------------------------------
SELECT AVG(sales) AS avg_order_value
FROM gold.fact_sales;


---------------------------------------------------------
-- 13) TOTAL SALES BY PRODUCT LINE
---------------------------------------------------------
SELECT product_line,
       SUM(f.sales) AS total_revenue
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS f
       ON p.product_key = f.product_key
GROUP BY product_line
ORDER BY total_revenue DESC;


---------------------------------------------------------
-- 14) TOP 5 COUNTRIES WITH HIGHEST REVENUE
---------------------------------------------------------
SELECT TOP 5 c.country,
       SUM(f.sales) AS total_revenue
FROM gold.dim_customers AS c
LEFT JOIN gold.fact_sales AS f
       ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC;


---------------------------------------------------------
-- 15) TOTAL QUANTITY SOLD BY PRODUCT
---------------------------------------------------------
SELECT p.product_name,
       SUM(f.quantity) AS total_quantity_sold
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS f
       ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC;


---------------------------------------------------------
-- 16) DAILY SALES TREND
---------------------------------------------------------
SELECT order_date,
       SUM(sales) AS daily_sales
FROM gold.fact_sales
GROUP BY order_date
ORDER BY order_date;


---------------------------------------------------------
-- 17) YEARLY SALES TREND
---------------------------------------------------------
SELECT DATETRUNC(year, order_date) AS sale_year,
       SUM(sales) AS yearly_sales
FROM gold.fact_sales
GROUP BY DATETRUNC(year, order_date)
ORDER BY sale_year;


---------------------------------------------------------
-- 18) TOTAL NUMBER OF ORDERS PER CUSTOMER
---------------------------------------------------------
SELECT customer_key,
       COUNT(*) AS total_orders
FROM gold.fact_sales
GROUP BY customer_key
ORDER BY total_orders DESC;


---------------------------------------------------------
-- 19) CATEGORY-WISE DISTINCT CUSTOMER COUNT
---------------------------------------------------------
SELECT p.category,
       COUNT(DISTINCT f.customer_key) AS unique_customers
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS f
       ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY unique_customers DESC;


---------------------------------------------------------
-- 20) REVENUE CONTRIBUTION PERCENTAGE BY CATEGORY
---------------------------------------------------------
WITH category_revenue AS (
    SELECT p.category,
           SUM(f.sales) AS category_revenue
    FROM gold.dim_products AS p
    LEFT JOIN gold.fact_sales AS f
           ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT category,
       category_revenue,
       category_revenue * 100.0 / (SELECT SUM(category_revenue) FROM category_revenue) AS revenue_percentage
FROM category_revenue
ORDER BY revenue_percentage DESC;


---------------------------------------------------------
-- 21) TOP CUSTOMERS BY AVERAGE ORDER SIZE
---------------------------------------------------------
SELECT c.customer_key,
       c.first_name,
       c.last_name,
       AVG(f.sales) AS avg_order_value
FROM gold.dim_customers AS c
LEFT JOIN gold.fact_sales AS f
       ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY avg_order_value DESC;
