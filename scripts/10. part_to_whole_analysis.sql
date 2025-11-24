-- ==============================================
-- PART-TO-WHOLE ANALYSIS
-- ==============================================
-- Goal: Identify which product categories contribute the most to overall sales
-- Includes both individual percentage and cumulative percentage for ranking

-- Step 1: Aggregate total sales per category
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales) AS total_sales
    FROM gold.fact_sales AS F
    LEFT JOIN gold.dim_products AS P
        ON F.product_key = P.product_key
    GROUP BY p.category
)

-- Step 2: Compute overall sales, running total, and percentages
SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,                          -- Total sales across all categories
    SUM(total_sales) OVER (ORDER BY total_sales) AS running_total,      -- Running total to track cumulative contribution
    CONCAT(ROUND(CAST(total_sales AS FLOAT) * 100.0 / SUM(total_sales) OVER (), 2), '%') AS percent_in_total, -- Individual contribution
    CONCAT(ROUND(SUM(CAST(total_sales AS FLOAT)) OVER (ORDER BY total_sales) * 100.0 / SUM(total_sales) OVER (), 2), '%') AS cumulative_percent -- Cumulative contribution
FROM category_sales
ORDER BY total_sales DESC;


-- ==============================================
-- ALTERNATIVE APPROACH USING A SECOND CTE
-- ==============================================

;WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales) AS total_sales
    FROM gold.fact_sales AS F
    LEFT JOIN gold.dim_products AS P
        ON F.product_key = P.product_key
    GROUP BY p.category
),

measure_metrics AS (
    SELECT *,
        SUM(total_sales) OVER () AS overall_sales,
        SUM(total_sales) OVER (ORDER BY total_sales) AS running_total,
        CONCAT(ROUND(CAST(total_sales AS FLOAT) * 100.0 / SUM(total_sales) OVER (), 2), '%') AS percent_in_total,
        CONCAT(ROUND(SUM(CAST(total_sales AS FLOAT)) OVER (ORDER BY total_sales) * 100.0 / SUM(total_sales) OVER (), 2), '%') AS cumulative_percent
    FROM category_sales
)

-- Step 3: Select metrics for reporting
SELECT 
    category,
    total_sales,
    overall_sales,
    running_total,
    percent_in_total,
    cumulative_percent
FROM measure_metrics
ORDER BY total_sales DESC;
