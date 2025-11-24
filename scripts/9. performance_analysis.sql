-- ==============================================
-- YEARLY PRODUCT PERFORMANCE ANALYSIS
-- ==============================================
-- Goal: Compare each product's yearly sales against average sales
--       and previous year sales to identify trends and performance patterns

-- Step 1: Aggregate yearly sales per product
WITH yearly_sales AS (
    SELECT
        YEAR(order_date) AS date_year,
        P.product_name,
        SUM(F.sales) AS current_sales
    FROM gold.fact_sales AS F
    LEFT JOIN gold.dim_products AS P
        ON F.product_key = P.product_key
    WHERE order_date IS NOT NULL
    GROUP BY P.product_name, YEAR(order_date)
)

-- Step 2: Compute differences, flags, and trends
SELECT 
    date_year,
    product_name,
    current_sales,
    
    -- Compare with previous year
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY date_year) AS prev_year_sales,
    
    -- Compare with average sales across all years
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    (current_sales - AVG(current_sales) OVER (PARTITION BY product_name)) AS avg_sales_diff,
    CASE
        WHEN (current_sales - AVG(current_sales) OVER (PARTITION BY product_name)) < 0 THEN 'Below Average'
        WHEN (current_sales - AVG(current_sales) OVER (PARTITION BY product_name)) > 0 THEN 'Above Average'
        ELSE 'Average'
    END AS avg_sales_flag,
    
    -- Year-over-year sales difference
    (current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY date_year)) AS sales_diff,
    CASE
        WHEN (current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY date_year)) > 0 THEN 'Increase'
        WHEN (current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY date_year)) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS sales_trend_flag

FROM yearly_sales
ORDER BY product_name, date_year;


-- ==============================================
-- ALTERNATIVE DETAILED PERFORMANCE METRICS
-- ==============================================

;WITH yearly_sales AS (
    SELECT
        YEAR(order_date) AS date_year,
        P.product_name,
        SUM(F.sales) AS current_sales
    FROM gold.fact_sales AS F
    LEFT JOIN gold.dim_products AS P
        ON F.product_key = P.product_key
    WHERE order_date IS NOT NULL
    GROUP BY P.product_name, YEAR(order_date)
),

sales_metrics AS (
    SELECT *,
        LAG(current_sales) OVER (PARTITION BY product_name ORDER BY date_year) AS prev_year_sales,
        AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales
    FROM yearly_sales
),

performance AS (
    SELECT
        date_year,
        product_name,
        current_sales,
        avg_sales,
        current_sales - avg_sales AS avg_diff,
        CASE
            WHEN current_sales - avg_sales > 0 THEN 'Above Average'
            WHEN current_sales - avg_sales < 0 THEN 'Below Average'
            ELSE 'Normal'
        END AS avg_sales_flag,
        
        prev_year_sales,
        current_sales - prev_year_sales AS sales_diff,
        CASE
            WHEN current_sales - prev_year_sales > 0 THEN 'Increase'
            WHEN current_sales - prev_year_sales < 0 THEN 'Decrease'
            ELSE 'No Change'
        END AS sales_trend_flag,
        
        -- Percentage growth vs previous year
        CASE
            WHEN prev_year_sales = 0 OR prev_year_sales IS NULL THEN NULL
            ELSE CONCAT(ROUND(CAST((current_sales - prev_year_sales) AS FLOAT) * 100.0 / NULLIF(prev_year_sales, 0), 2), '%')
        END AS sales_growth_percent,
        
        -- Ranking metrics
        RANK() OVER (PARTITION BY date_year ORDER BY current_sales DESC) AS yearly_rank,
        PERCENT_RANK() OVER (PARTITION BY date_year ORDER BY current_sales DESC) AS percentile_rank,
        
        -- Cumulative and percentage metrics
        SUM(current_sales) OVER (PARTITION BY product_name ORDER BY date_year) AS cumulative_sales,
        SUM(current_sales) OVER (ORDER BY date_year) AS total_sales_yearwise,
        ROUND(current_sales * 100.0 / SUM(current_sales) OVER (ORDER BY date_year), 2) AS percent_of_total,
        
        -- Rolling 3-year average
        AVG(current_sales) OVER (PARTITION BY product_name ORDER BY date_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_3yr,
        
        -- Consistency flag
        CASE 
            WHEN current_sales > avg_sales AND LAG(current_sales) OVER (PARTITION BY product_name ORDER BY date_year) > avg_sales THEN 'Consistent Performer'
            ELSE NULL
        END AS consistency_flag
    FROM sales_metrics
)

-- Step 3: Final performance report
SELECT *
FROM performance
-- WHERE consistency_flag IS NOT NULL  -- Uncomment to focus on consistent performers
ORDER BY product_name, date_year;
