/* ============================================================
   PRODUCT & CATEGORY PERFORMANCE MODEL
   - Counts unique products in each category/subcategory
   - Calculates category-level totals for benchmarking
   - Aggregates product performance across its full sales history
   - Adds recency, product segmentation, contribution %, 
     customer penetration %, and ranking within category
   ============================================================ */

---------------------------------------------------------------
-- 1. Count distinct products inside each category grouping
---------------------------------------------------------------

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH product_count AS (
    SELECT 
        category,
        subcategory,
        COUNT(DISTINCT product_key) AS total_product_in_category
    FROM gold.dim_products
    GROUP BY category, subcategory
),

---------------------------------------------------------------
-- 2. Category-level performance for contribution comparisons
---------------------------------------------------------------
category_sales AS (
    SELECT 
        p.category,
        p.subcategory,
        SUM(f.sales) AS total_sales_category,
        COUNT(DISTINCT f.customer_key) AS total_customers_category,
        SUM(f.quantity) AS total_quantity_category          -- useful for share-of-volume
    FROM gold.fact_sales f
    JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    GROUP BY p.category, p.subcategory
),

---------------------------------------------------------------
-- 3. Full product-level aggregation across its entire lifespan
---------------------------------------------------------------
product_aggregation AS (
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        b.price,
        p.cost,
        COUNT(DISTINCT b.customer_key) AS customer_count,
        COUNT(DISTINCT b.order_number) AS total_orders,
        SUM(b.sales) AS total_sales,
        SUM(b.quantity) AS total_quantity,

        /* Lifecycle metrics */
        MIN(b.order_date) AS first_order_date,
        MAX(b.order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(b.order_date), MAX(b.order_date)) AS lifespan,

        pc.total_product_in_category
    FROM gold.fact_sales b
    JOIN gold.dim_products p
        ON b.product_key = p.product_key
    LEFT JOIN product_count pc
        ON p.category = pc.category
       AND p.subcategory = pc.subcategory
    GROUP BY 
        p.product_key, p.product_name,
        p.category, p.subcategory,
        b.price, p.cost,
        pc.total_product_in_category
)

---------------------------------------------------------------
-- 4. Final enriched result with additional KPIs
---------------------------------------------------------------
SELECT
    pa.product_key,
    pa.product_name,
    pa.category,
    pa.subcategory,
    pa.price,
    pa.cost,
    pa.customer_count,
    pa.total_orders,
    pa.total_sales,
    pa.total_quantity,
    pa.first_order_date,
    pa.last_order_date,
    pa.lifespan,
    pa.total_product_in_category,

    /* Months since last purchase */
    DATEDIFF(MONTH, pa.last_order_date, GETDATE()) AS recency,

    /* Simple performance tiers based on revenue */
    CASE
        WHEN pa.total_sales > 50000 THEN 'High Performer'
        WHEN pa.total_sales >= 10000 THEN 'Mid Performer'
        ELSE 'Low Performer'
    END AS product_segment,

    /* Ordering behavior */
    ROUND(CAST(pa.total_sales AS FLOAT) / NULLIF(pa.total_orders, 0), 2) AS avg_order_revenue,
    ROUND(CAST(pa.total_quantity AS FLOAT) / NULLIF(pa.total_orders, 0), 2) AS avg_quantity_per_order,

    /* Revenue consistency across lifespan */
    ROUND(CAST(pa.total_sales AS FLOAT) / NULLIF(pa.lifespan, 0), 2) AS avg_monthly_revenue,

    /* Simple product lifetime value proxy */
    ROUND(
        (CAST(pa.total_sales AS FLOAT) / NULLIF(pa.lifespan, 0)) * pa.lifespan, 
        2
    ) AS PLV,

    /* Category benchmarks */
    cs.total_sales_category,
    cs.total_customers_category,
    cs.total_quantity_category,

    /* Product’s relative contribution inside category */
    ROUND(CAST(pa.total_sales AS FLOAT) / NULLIF(cs.total_sales_category, 0) * 100, 2)
        AS percent_of_category_sales,

    ROUND(CAST(pa.total_quantity AS FLOAT) / NULLIF(cs.total_quantity_category, 0) * 100, 2)
        AS percent_of_category_volume,

    /* Penetration of customer base within category */
    ROUND(CAST(pa.customer_count AS FLOAT) / NULLIF(cs.total_customers_category, 0) * 100, 2)
        AS customer_penetration_pct,

    /* Ranking products inside a category by total sales */
    DENSE_RANK() OVER (
        PARTITION BY pa.category, pa.subcategory 
        ORDER BY pa.total_sales DESC
    ) AS rank_in_category

FROM product_aggregation pa
LEFT JOIN category_sales cs
    ON pa.category = cs.category
   AND pa.subcategory = cs.subcategory

--ORDER BY 
--    pa.category,
--    pa.subcategory,
--    pa.total_sales DESC;


/* Explanation of Key Metrics

customer_count: number of distinct customers who bought the product.

total_orders: how many times the product was ordered.

total_sales: total revenue generated by the product.

total_quantity: total units sold.

first_order_date / last_order_date: the earliest and latest dates the product was sold.

lifespan: number of months between first and last sale.

total_product_in_category: how many different products exist in the same category.

recency: days since the product was last purchased.

product_segment: simple performance label (eg High, Mid, Low) based on revenue.

avg_order_revenue: average revenue per order.

avg_quantity_per_order: average units sold per order.

avg_monthly_revenue: average revenue generated per month.

PLV: product lifetime value (total revenue across its lifespan).

total_sales_category: total revenue generated by all products in the category.

total_customers_category: count of customers who bought anything in the category.

total_quantity_category: total units sold for the entire category.

percent_of_category_sales: product’s share of category revenue.

percent_of_category_volume: product’s share of category units sold.

customer_penetration_pct: percent of category customers who bought this product.

rank_in_category: position of the product within its category based on revenue.*/