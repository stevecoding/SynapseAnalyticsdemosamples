-- ****** [ACTION REQUIRED] ****** 
-- Enter the name of the database where you would like to create External Table
DECLARE @DBNAME VARCHAR(100) SET @DBNAME = 'CustomerAnalyticsDatabase' -- Enter a name for the database that you would like to create
DECLARE @CREATE_TEMPLATE VARCHAR(MAX) SET @CREATE_TEMPLATE = 'IF NOT EXISTS(SELECT * FROM sys.databases WHERE name=''{DBNAME}'') CREATE DATABASE {DBNAME}'
DECLARE @SQL_SCRIPT VARCHAR(MAX) SET @SQL_SCRIPT = REPLACE(@CREATE_TEMPLATE, '{DBNAME}', @DBNAME)
EXECUTE (@SQL_SCRIPT)
GO

-- ****** [ACTION REQUIRED] ****** 
--Step 1: Create master key for the database
Use CustomerAnalyticsDatabase --Enter the name of the database where you would like to create External Table 
IF NOT EXISTS(SELECT * FROM sys.symmetric_keys WHERE name LIKE '%DatabaseMasterKey%')
	CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Str@ng123P@assword!' -- Enter a strong password
GO

--Step 2: Create Database Scoped Credentials to access storage account
Use CustomerAnalyticsDatabase
IF NOT EXISTS(SELECT * FROM sys.database_credentials WHERE name = 'SynapseUserIdentity')
	CREATE DATABASE SCOPED CREDENTIAL SynapseUserIdentity WITH IDENTITY = 'User Identity'
GO

-- Step 3: Create External File Format
Use CustomerAnalyticsDatabase
IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'ParquetFormat') 
	CREATE EXTERNAL FILE FORMAT [ParquetFormat] 
	WITH ( FORMAT_TYPE = PARQUET)
GO

-- Step 4: Create External Data Source
Use CustomerAnalyticsDatabase
IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'twtdatastorage') 
	CREATE EXTERNAL DATA SOURCE [twtdatastorage] 
	WITH (
		LOCATION   = 'https://{storage-account-name}.dfs.core.windows.net/analytics',
		CREDENTIAL = SynapseUserIdentity
	)
GO

-- Step 5: Create External Table
Use CustomerAnalyticsDatabase
CREATE EXTERNAL TABLE CustomerSalesExtTable
	WITH (
			LOCATION = 'customer_analytics_ex/',
			DATA_SOURCE = [twtdatastorage],
			FILE_FORMAT = [ParquetFormat]
	)
	AS
	WITH Aggregates AS (
	SELECT *
	FROM OPENROWSET(
			BULK 'https://{storage-account-name}.dfs.core.windows.net/analytics/customer_sales/customer_sales.parquet',
			FORMAT='PARQUET'
		) AS [r1]
	), Analytics AS (
	SELECT *
	FROM OPENROWSET(
			BULK 'https://{storage-account-name}.dfs.core.windows.net/analytics/web_analytics/web_analytics.parquet',
			FORMAT='PARQUET'
		) AS [r2]
	)
	SELECT Aggregates.REGION_CODE, COUNT(*) AS 'OFFERING'
	FROM Aggregates 
	JOIN Analytics ON Aggregates.ACCOUNT_NUMBER = Analytics.ACCOUNT_NUMBER
	WHERE Aggregates.TOTAL_SPENT < (SELECT AVG(TOTAL_SPENT) FROM Aggregates) 
	AND Analytics.CATEGORY_GARDENING_PAGE_EVENTS > (SELECT AVG(CATEGORY_GARDENING_PAGE_EVENTS) FROM Analytics)
	GROUP BY Aggregates.REGION_CODE
	ORDER BY Aggregates.REGION_CODE
GO

-- Step 6: Query TOP 100 rows
Use CustomerAnalyticsDatabase
SELECT TOP 100 * FROM CustomerSalesExtTable
GO

