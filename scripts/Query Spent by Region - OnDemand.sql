SELECT REGION_CODE, AVG(TOTAL_SPENT) AS 'AVERAGE_SPENT'
FROM
    OPENROWSET(
        BULK 'https://{storage-account-name}.dfs.core.windows.net/analytics/customer_sales/customer_sales.parquet',
        FORMAT='PARQUET'
    ) AS [r]
GROUP BY REGION_CODE
ORDER BY REGION_CODE
