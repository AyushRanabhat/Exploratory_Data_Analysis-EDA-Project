/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/
USE MASTER

-- Drop and recreate the 'DataWarehouseAnalytics' database

IF EXISTS ( SELECT 1 FROM sys.databases where name = 'DataWareHouseAnalytics')
    BEGIN
           ALTER DATABASE DataWareHouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
           DROP DATABASE DataWareHouseAnalytics;
    END;
GO

-- Create the 'DataWarehouseAnalytics' database

CREATE DATABASE DataWareHouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas

CREATE SCHEMA gold;
GO

-- CREATE TABLES

IF OBJECT_ID ('gold.dim_customers','U') IS NOT NULL
	DROP TABLE gold.dim_customers

CREATE TABLE gold.dim_customers (
        customer_key INT,
        customer_id INT,
        customer_number NVARCHAR (50),
        first_name NVARCHAR (50),
        last_name NVARCHAR (50),
        country NVARCHAR(50),
        marital_status NVARCHAR (50),
        gender NVARCHAR(50),
        birth_date DATE,
        create_date DATE
);
GO

IF OBJECT_ID ('gold.dim_products','U') IS NOT NULL
	DROP TABLE gold.dim_products


CREATE TABLE gold.dim_products (
        product_key INT,
        product_id INT,
        product_number NVARCHAR (50),
        product_name NVARCHAR (50),
        category_id NVARCHAR (50),
        category NVARCHAR (50),
        subcategory NVARCHAR (50),
        maintenance NVARCHAR (50),
        cost INT,   
        product_line NVARCHAR (50),
        start_date DATE        
);
GO

IF OBJECT_ID ('gold.fact_sales','U') IS NOT NULL
	DROP TABLE gold.fact_sales

CREATE TABLE gold.fact_sales (
       order_number NVARCHAR(50),
       product_key INT,
       customer_key INT,
       order_date DATE,
       shipping_date DATE,
       due_date DATE, 
       sales INT,
       quantity TINYINT,
       price INT
);
GO

TRUNCATE TABLE gold.dim_customers

BULK INSERT gold.dim_customers 
FROM 'C:\SQL-projects\MY EDA PROJECT\datasets\csv_files\gold.dim_customers.csv'
WITH 
    ( FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      TABLOCK
);
GO


TRUNCATE TABLE gold.dim_products

BULK INSERT gold.dim_products 
FROM 'C:\SQL-projects\MY EDA PROJECT\datasets\csv_files\gold.dim_products.csv'
WITH 
    ( FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      TABLOCK
);
GO


TRUNCATE TABLE gold.fact_sales

BULK INSERT gold.fact_sales 
FROM 'C:\SQL-projects\MY EDA PROJECT\datasets\csv_files\gold.fact_sales.csv'
WITH 
    ( FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      TABLOCK
);
GO