/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS (
    SELECT 
        f.order_number,
        f.product_key,
        f.customer_key,
        f.order_date,
        f.sales,
        f.quantity,
        f.price,
        c.customer_number,    
        c.first_name + ' ' + c.last_name AS fullname,
        c.country,
        c.marital_status,
        c.gender,
        DATEDIFF(YEAR, birth_date, GETDATE()) AS age
    FROM gold.fact_sales AS F
    LEFT JOIN gold.dim_customers AS C
        ON F.customer_key = C.customer_key
    WHERE order_date IS NOT NULL
),

customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,    
        fullname,
        age,
        MAX(order_date) AS last_order_date,
        MIN(order_date) AS first_order_date,
        SUM(sales) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT order_number) AS total_order,
        COUNT(DISTINCT product_key) AS total_product,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,    
        fullname,
        age
)

SELECT
    customer_key,
    customer_number,    
    fullname,
    age,

    -- Age segment
    CASE    
        WHEN age <= 18 THEN 'Underage'
        WHEN age BETWEEN 18 AND 29 THEN '18-29'
        WHEN age BETWEEN 29 AND 39 THEN '29-39'
        WHEN age BETWEEN 39 AND 49 THEN '39-49'
        ELSE 'Above 50'
    END AS age_segment,

    total_sales,

    -- Segment logic
    CASE
        WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
        WHEN total_sales <= 5000 AND lifespan >= 12 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    total_quantity,
    total_order,
    total_product,
    lifespan,

    -- Recency
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    -- Average order value
    CASE 
        WHEN total_order = 0 THEN 0
        ELSE ROUND(CAST(total_sales AS FLOAT) * 1.0 / total_order,2)
    END AS avg_order_value,

    -- Average monthly spend
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE ROUND(CAST(total_sales AS FLOAT)* 1.0 / lifespan ,2)
    END AS avg_monthly_spend,

    -- Customer lifetime value
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE ROUND(CAST(total_sales AS FLOAT) * 1.0 / lifespan,2) * lifespan
    END AS clv,

    -- Average quantity per order
    CASE 
        WHEN total_order = 0 THEN 0
        ELSE ROUND(CAST(total_quantity AS FLOAT )* 1.0 / total_order,2)
    END AS avg_qty_per_order,

    -- Order frequency (months per order)
    CASE 
        WHEN total_order = 0 THEN NULL
        ELSE ROUND(CAST(lifespan AS FLOAT)* 1.0 / total_order ,2)
    END AS order_frequency,

    -- Activity flag
    CASE
        WHEN DATEDIFF(MONTH, last_order_date, GETDATE()) <= 3 THEN 'Active'
        ELSE 'At Risk'
    END AS activity_flag,

    -- First Purchase Year
    YEAR(first_order_date) AS first_order_year,

    -- Contribution to company revenue
    ROUND(CAST(
        total_sales AS FLOAT) * 100.0 / SUM(total_sales) OVER (),
        2
    ) AS percent_contribution,

    -- Ranking by sales
    DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank,

    -- Days between first and last order
    DATEDIFF(DAY, first_order_date, last_order_date) AS days_active

FROM customer_aggregation;
