-- ==============================================
-- PRODUCT COST SEGMENTATION
-- ==============================================

-- Step 1: Find minimum and maximum product costs
-- This helps to understand the range of product pricing before segmentation
WITH product_costs AS (
    SELECT 
        product_name,
        SUM(cost) AS total_cost
    FROM gold.dim_products
    GROUP BY product_name
    HAVING SUM(cost) > 0
)
SELECT 
    product_name,
    total_cost,
    MIN(total_cost) OVER () AS min_cost,
    MAX(total_cost) OVER () AS max_cost
FROM product_costs;


-- Step 2: Segment products into cost ranges
-- Assign products to 'below 500', '500-1500', or 'High' based on their cost
WITH product_seg AS (
    SELECT 
        product_key,
        product_name,
        cost,
        CASE
            WHEN cost < 500 THEN 'below 500'
            WHEN cost BETWEEN 500 AND 1500 THEN '500-1500'
            ELSE 'High'
        END AS cost_ranges
    FROM gold.dim_products
)
-- Count how many products fall into each segment
SELECT 
    cost_ranges,
    COUNT(product_key) AS product_count
FROM product_seg
GROUP BY cost_ranges
ORDER BY product_count DESC;



-- ==============================================
-- CUSTOMER SEGMENTATION BASED ON TOTAL SPENDING
-- ==============================================

-- Step 1: Calculate customer lifespan and total spending
-- Lifespan is in months; total spending helps differentiate VIP vs regular customers
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(F.sales) AS total_sales,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.dim_customers AS c
    LEFT JOIN gold.fact_sales AS F
        ON c.customer_key = F.customer_key
    GROUP BY c.customer_key
),

-- Step 2: Assign customers to segments
-- VIP: >= 12 months history and spending > 5000
-- Regular: >= 12 months history and spending <= 5000
-- New: < 12 months of history
customer_segmentation AS (
    SELECT
        customer_key,
        total_sales,
        lifespan,
        CASE
            WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
            WHEN total_sales <= 5000 AND lifespan >= 12 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
)

-- Step 3: Count customers in each segment
SELECT 
    customer_segment,
    COUNT(*) AS total_customers
FROM customer_segmentation
GROUP BY customer_segment
ORDER BY customer_segment;


-- ==============================================
-- ALTERNATIVE FORMATTING OF CUSTOMER SEGMENTATION
-- ==============================================

;WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(F.sales) AS total_sales,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.dim_customers AS c
    LEFT JOIN gold.fact_sales AS F
        ON c.customer_key = F.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(*) AS total_customers
FROM (
    SELECT
        customer_key,
        total_sales,
        lifespan,
        CASE
            WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
            WHEN total_sales <= 5000 AND lifespan >= 12 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) t
GROUP BY customer_segment
ORDER BY customer_segment;
