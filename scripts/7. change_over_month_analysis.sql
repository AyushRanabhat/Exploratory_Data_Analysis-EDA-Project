-- ==============================================
-- CUSTOMER AND SALES TRENDS ANALYSIS
-- ==============================================
-- Track overall and month-wise sales and customer metrics


-------------------------------------------------------------
-- 1. Summary of Customer and Sales Trends by Year
-------------------------------------------------------------
SELECT
    YEAR(order_date) AS date_year,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS no_of_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY total_sales DESC;


-------------------------------------------------------------
-- 2. Monthly Sales and Customer Trends Broken Down by Year
-------------------------------------------------------------
SELECT
    YEAR(order_date) AS date_year,
    MONTH(order_date) AS date_month,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS no_of_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE MONTH(order_date) IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY date_year, date_month ASC;


-------------------------------------------------------------
-- 3. Month-Level Sales and Customer Trends (Using Date Truncation)
-------------------------------------------------------------
SELECT
    DATETRUNC(MONTH, order_date) AS order_month,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS no_of_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE MONTH(order_date) IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY order_month ASC;


-------------------------------------------------------------
-- 4. Year-Level Sales and Customer Trends (Using Date Truncation)
-------------------------------------------------------------
SELECT
    DATETRUNC(YEAR, order_date) AS order_year,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS no_of_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE MONTH(order_date) IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
ORDER BY order_year ASC;


-------------------------------------------------------------
-- 5. Month-Level Sales and Customer Trends With Formatted Dates
-------------------------------------------------------------
SELECT
    FORMAT(order_date,'yyyy-MMM') AS order_month,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT customer_key) AS no_of_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE MONTH(order_date) IS NOT NULL
GROUP BY FORMAT(order_date,'yyyy-MMM')
ORDER BY order_month ASC;
