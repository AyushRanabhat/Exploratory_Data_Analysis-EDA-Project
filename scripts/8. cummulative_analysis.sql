-- ==============================================
-- CUMULATIVE ANALYSIS OF SALES DATA
-- ==============================================
-- This set of queries tracks cumulative and average sales
-- over time at different granularities (yearly, monthly).

/* ===================================================
   1. Total Sales Per Year with Running Total
   =================================================== */
WITH running_total_year AS (
    SELECT
        YEAR(order_date) AS year,
        SUM(sales) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
)
SELECT 
    year,
    total_sales,
    SUM(total_sales) OVER (ORDER BY year) AS cumulative_sales
FROM running_total_year
ORDER BY year;


/* ===================================================
   2. Total Sales Per Month with Running Total
   =================================================== */
WITH running_total_month AS (
    SELECT
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(sales) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    year,
    month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY year, month) AS cumulative_sales
FROM running_total_month
ORDER BY year, month;


/* ===================================================
   3. Total Sales Per Month Using Subquery
   =================================================== */
SELECT 
    order_month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total
FROM (
    SELECT 
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) t
ORDER BY order_month;


/* ===================================================
   4. Average Price Per Year with Running Average
   =================================================== */
WITH running_average AS (
    SELECT 
        YEAR(order_date) AS year,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
)
SELECT 
    year,
    avg_price,
    AVG(avg_price) OVER (ORDER BY year) AS cumulative_avg_price
FROM running_average
ORDER BY year;


/* ===================================================
   5. Yearly Sales Growth %
   =================================================== */
WITH running_total_year AS (
    SELECT
        YEAR(order_date) AS year,
        SUM(sales) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
)
SELECT
    year,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year) AS previous_year_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY year)) * 100.0 /
        LAG(total_sales) OVER (ORDER BY year), 2
    ) AS growth_percentage
FROM running_total_year
ORDER BY year;


/* ===================================================
   6. Monthly Average Sales
   =================================================== */
WITH running_total_month AS (
    SELECT
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(sales) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    year,
    month,
    total_sales,
    ROUND(total_sales / COUNT(*), 2) AS avg_monthly_sales
FROM running_total_month
GROUP BY year, month, total_sales
ORDER BY year, month;
