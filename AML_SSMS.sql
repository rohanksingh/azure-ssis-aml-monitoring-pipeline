IF DB_ID('AML_Cloud_ETL') IS NULL
    CREATE DATABASE AML_Cloud_ETL;
GO

USE AML_Cloud_ETL;

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bronze';


USE AML_Cloud_ETL;

SELECT COUNT(*) AS TotalTransactions
FROM bronze.AML_Transactions_Raw;


select * from bronze.AML_Transactions_Raw;

USE AML_Cloud_ETL;

SELECT
    COUNT(*) AS TotalTransactions,
    MIN(LoadTimestamp) AS FirstLoad,
    MAX(LoadTimestamp) AS LastLoad
FROM bronze.AML_Transactions_Raw;

USE AML_Cloud_ETL;

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'silver';


USE AML_Cloud_ETL;

SELECT
    COUNT(*) AS TotalSilverRecords,
    SUM(CASE WHEN TransactionDateTime IS NULL THEN 1 ELSE 0 END)
        AS InvalidTimestamps,
    SUM(CASE WHEN AmountReceived IS NULL THEN 1 ELSE 0 END)
        AS InvalidReceivedAmounts,
    SUM(CASE WHEN AmountPaid IS NULL THEN 1 ELSE 0 END)
        AS InvalidPaidAmounts,
    SUM(CASE WHEN IsLaundering IS NULL THEN 1 ELSE 0 END)
        AS InvalidLaunderingFlags
FROM silver.AML_Transactions_Clean;


SELECT
    COUNT(*) AS TotalSilverRecords,

    SUM(CASE WHEN TransactionDateTime IS NULL
        THEN 1 ELSE 0 END) AS InvalidTimestamps,

    SUM(CASE WHEN AmountReceived IS NULL
        THEN 1 ELSE 0 END) AS InvalidReceivedAmounts,

    SUM(CASE WHEN AmountPaid IS NULL
        THEN 1 ELSE 0 END) AS InvalidPaidAmounts,

    SUM(CASE WHEN IsLaundering IS NULL
        THEN 1 ELSE 0 END) AS InvalidLaunderingFlags,

    SUM(CASE WHEN IsLaundering = 1
        THEN 1 ELSE 0 END) AS ActualLaunderingTransactions

FROM silver.AML_Transactions_Clean;


select top 10 [timestamp] as original_timestamp
from bronze.AML_Transactions_Raw;


USE AML_Cloud_ETL;

SELECT
    COUNT(*) AS TotalSilverRecords,
    SUM(CASE WHEN TransactionDateTime IS NULL
        THEN 1 ELSE 0 END) AS InvalidTimestamps,
    MIN(TransactionDateTime) AS EarliestTransaction,
    MAX(TransactionDateTime) AS LatestTransaction
FROM silver.AML_Transactions_Clean;


USE AML_Cloud_ETL;

SELECT
    COUNT(*) AS TotalRecords,
    COUNT(TransactionDateTime) AS ValidTimestamps,
    SUM(CASE WHEN TransactionDateTime IS NULL
        THEN 1 ELSE 0 END) AS InvalidTimestamps,
    SUM(CASE WHEN IsLaundering = 1
        THEN 1 ELSE 0 END) AS ActualLaunderingCases
FROM silver.AML_Transactions_Clean;


USE AML_Cloud_ETL;

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'gold';


USE AML_Cloud_ETL;

SELECT
    COUNT(*) AS TotalHighValueAlerts,
    SUM(CASE WHEN IsLaundering = 1 THEN 1 ELSE 0 END)
        AS KnownLaunderingCasesFlagged
FROM gold.AML_Transaction_Alerts
WHERE AlertRule = 'HIGH_VALUE_TRANSACTION';



USE AML_Cloud_ETL;

SELECT
    PaymentFormat,
    COUNT(*) AS TotalTransactions,
    MIN(AmountPaid) AS MinimumAmount,
    MAX(AmountPaid) AS MaximumAmount
FROM silver.AML_Transactions_Clean
GROUP BY PaymentFormat
ORDER BY TotalTransactions DESC;



SELECT
    AlertRule,
    COUNT(*) AS TotalAlerts,
    SUM(CASE WHEN IsLaundering = 1 THEN 1 ELSE 0 END)
        AS KnownLaunderingCasesFlagged
FROM gold.AML_Transaction_Alerts
GROUP BY AlertRule;





SELECT
    COUNT(DISTINCT RawTransactionID) AS UniqueFlaggedTransactions,
    COUNT(DISTINCT CASE
        WHEN IsLaundering = 1 THEN RawTransactionID
    END) AS UniqueKnownLaunderingCasesFlagged
FROM gold.AML_Transaction_Alerts;