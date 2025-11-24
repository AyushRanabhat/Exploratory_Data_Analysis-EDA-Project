-- ==============================================
-- DATABASE EXPLORATION
-- ==============================================
-- Explore tables, columns, keys, and relationships in the database.

-------------------------------------------------------------
-- 1. Explore all objects (tables and views) in the database
-------------------------------------------------------------
SELECT *
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-------------------------------------------------------------
-- 2. Explore all columns in a specific table
-------------------------------------------------------------
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products'
ORDER BY ORDINAL_POSITION;

-- Example: Explore columns for all tables
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-------------------------------------------------------------
-- 3. Explore key column usage (primary and foreign keys)
-------------------------------------------------------------
SELECT *
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
ORDER BY TABLE_NAME, COLUMN_NAME;

-------------------------------------------------------------
-- 4. Explore constraints on tables
-------------------------------------------------------------
SELECT *
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
ORDER BY TABLE_NAME, CONSTRAINT_TYPE;

-------------------------------------------------------------
-- 5. Explore referential relationships (foreign keys)
-------------------------------------------------------------
SELECT 
    fk.CONSTRAINT_NAME,
    fk.TABLE_NAME AS foreign_table,
    fk.COLUMN_NAME AS foreign_column,
    pk.TABLE_NAME AS primary_table,
    pk.COLUMN_NAME AS primary_column
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE fk
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE pk
    ON fk.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
WHERE fk.TABLE_NAME != pk.TABLE_NAME
ORDER BY fk.TABLE_NAME, fk.COLUMN_NAME;

-------------------------------------------------------------
-- 6. Explore indexes on tables
-------------------------------------------------------------
SELECT *
FROM sys.indexes
WHERE object_id = OBJECT_ID('dim_products')
ORDER BY name;

-------------------------------------------------------------
-- 7. Count of rows per table
-------------------------------------------------------------
SELECT 
    t.NAME AS table_name,
    p.rows AS row_count
FROM sys.tables t
JOIN sys.partitions p
    ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)  -- heap or clustered index
GROUP BY t.NAME, p.rows
ORDER BY row_count DESC;
