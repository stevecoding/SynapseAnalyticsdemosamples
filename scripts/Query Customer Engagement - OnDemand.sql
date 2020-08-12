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