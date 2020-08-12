SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://{storage-account-name}.dfs.core.windows.net/analytics/customer_sales/customer_sales.parquet',
        FORMAT='PARQUET'
    ) AS [r];
