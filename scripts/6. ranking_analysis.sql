-- ==============================================
-- RANKING ANALYSIS
-- ==============================================
-- Goal: Identify top and bottom performing products and customers based on sales, quantity, frequency, and growth.

-------------------------------------------------------------
-- 1. Top 5 Products by Total Revenue
-------------------------------------------------------------
SELECT TOP 5
    P.product_name,
    SUM(F.sales) AS total_sales
FROM gold.dim_products AS P
LEFT JOIN gold.fact_sales AS F
    ON P.product_key = F.product_key
GROUP BY P.product_name
ORDER BY total_sales DESC;

-- Alternative using ROW_NUMBER
SELECT TOP 5
    P.product_name,
    SUM(F.sales) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(F.sales) DESC) AS rankings
FROM gold.dim_products AS P
LEFT JOIN gold.fact_sales AS F
    ON P.product_key = F.product_key
GROUP BY P.product_name
ORDER BY total_revenue DESC;

-------------------------------------------------------------
-- 2. Bottom 5 Products by Total Revenue
-------------------------------------------------------------
SELECT TOP 5
    P.product_name,
    SUM(F.sales) AS total_sales
FROM gold.dim_products AS P
LEFT JOIN gold.fact_sales AS F
    ON P.product_key = F.product_key
GROUP BY P.product_name
ORDER BY total_sales ASC;

-------------------------------------------------------------
-- 3. Top 10 Customers by Total Revenue
-------------------------------------------------------------
SELECT TOP 10
    C.customer_key,
    C.first_name,
    C.last_name,
    SUM(F.sales) AS total_revenue
FROM gold.dim_customers AS C
LEFT JOIN gold.fact_sales AS F
    ON C.customer_key = F.customer_key
GROUP BY C.customer_key, C.first_name, C.last_name
ORDER BY total_revenue DESC;

-- Alternative using ROW_NUMBER
SELECT *
FROM (
    SELECT
        C.customer_key,
        C.first_name,
        C.last_name,
        SUM(F.sales) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(F.sales) DESC) AS rankings
    FROM gold.dim_customers AS C
    LEFT JOIN gold.fact_sales AS F
        ON C.customer_key = F.customer_key
    GROUP BY C.customer_key, C.first_name, C.last_name
) t
WHERE rankings <= 10;

-------------------------------------------------------------
-- 4. Top 3 Customers with Fewest Orders
-------------------------------------------------------------
SELECT TOP 3
    C.customer_key,
    C.first_name,
    C.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.dim_customers AS C
LEFT JOIN gold.fact_sales AS F
    ON C.customer_key = F.customer_key
GROUP BY C.customer_key, C.first_name, C.last_name
ORDER BY total_orders ASC;

-------------------------------------------------------------
-- 5. Customers with Only One Order
-------------------------------------------------------------
WITH customer_orders AS (
    SELECT 
        C.customer_key,
        C.first_name,
        C.last_name,
        COUNT(DISTINCT F.order_number) AS total_orders
    FROM gold.dim_customers AS C
    LEFT JOIN gold.fact_sales AS F
        ON C.customer_key = F.customer_key
    GROUP BY C.customer_key, C.first_name, C.last_name
    HAVING COUNT(DISTINCT F.order_number) = 1
)
SELECT *,
       ROW_NUMBER() OVER (ORDER BY total_orders ASC) AS listings
FROM customer_orders
ORDER BY total_orders ASC;

-------------------------------------------------------------
-- 6. Top 5 Products by Quantity Sold
-------------------------------------------------------------
SELECT TOP 5
    P.product_name,
    SUM(F.quantity) AS total_quantity
FROM gold.dim_products AS P
LEFT JOIN gold.fact_sales AS F
    ON P.product_key = F.product_key
GROUP BY P.product_name
ORDER BY total_quantity DESC;

-------------------------------------------------------------
-- 7. Top 5 Customers by Quantity Purchased
-------------------------------------------------------------
SELECT TOP 5
    C.customer_key,
    C.first_name,
    C.last_name,
    SUM(F.quantity) AS total_quantity
FROM gold.dim_customers AS C
LEFT JOIN gold.fact_sales AS F
    ON C.customer_key = F.customer_key
GROUP BY C.customer_key, C.first_name, C.last_name
ORDER BY total_quantity DESC;

-------------------------------------------------------------
-- 8. Top 10 Most Frequently Ordered Products
-------------------------------------------------------------
SELECT TOP 10
    P.product_name,
    COUNT(DISTINCT F.order_number) AS order_frequency
FROM gold.dim_products AS P
LEFT JOIN gold.fact_sales AS F
    ON P.product_key = F.product_key
GROUP BY P.product_name
ORDER BY order_frequency DESC;

-------------------------------------------------------------
-- 9. Top and Bottom Products by Revenue per Unit Sold
-------------------------------------------------------------
-- Top 10
SELECT TOP 10
    P.product_name,
    SUM(F.sales)/NULLIF(SUM(F.quantity),0) AS revenue_per_unit
FROM gold.dim_products AS P
LEFT JOIN gold.fact_sales AS F
    ON P.product_key = F.product_key
GROUP BY P.product_name
ORDER BY revenue_per_unit DESC;

-- Bottom 5
SELECT TOP 5
    P.product_name,
    SUM(F.sales)/NULLIF(SUM(F.quantity),0) AS revenue_per_unit
FROM gold.dim_products AS P
LEFT JOIN gold.fact_sales AS F
    ON P.product_key = F.product_key
GROUP BY P.product_name
HAVING SUM(F.sales) IS NOT NULL
ORDER BY revenue_per_unit ASC;

-------------------------------------------------------------
-- 10. Top 5 Customers with Longest Purchase History
-------------------------------------------------------------
SELECT TOP 5
    C.customer_key,
    C.first_name,
    C.last_name,
    DATEDIFF(DAY, MIN(F.order_date), MAX(F.order_date)) AS activity_span_days
FROM gold.dim_customers AS C
LEFT JOIN gold.fact_sales AS F
    ON C.customer_key = F.customer_key
GROUP BY C.customer_key, C.first_name, C.last_name
ORDER BY activity_span_days DESC;

-------------------------------------------------------------
-- 11. Top 5 Products with Fastest Sales Growth (MoM)
-------------------------------------------------------------
WITH monthly_sales AS (
    SELECT 
        P.product_name,
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS sales_month,
        SUM(F.sales) AS monthly_revenue
    FROM gold.dim_products AS P
    LEFT JOIN gold.fact_sales AS F
        ON P.product_key = F.product_key
    GROUP BY P.product_name, DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
),
growth_calc AS (
    SELECT 
        product_name,
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (PARTITION BY product_name ORDER BY sales_month) AS prev_month_sales
    FROM monthly_sales
)
SELECT TOP 5
    product_name,
    sales_month,
    monthly_revenue,
    prev_month_sales,
    (monthly_revenue - prev_month_sales) AS revenue_growth
FROM growth_calc
WHERE prev_month_sales IS NOT NULL
ORDER BY revenue_growth DESC;
