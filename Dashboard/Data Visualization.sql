USE Online_Retail;
GO

WITH CustomerPurchases AS (
    SELECT
        CustomerID,
        CAST(InvoiceDate AS DATE) AS PurchaseDate
    FROM dbo.Online_Retail
    WHERE CustomerID IS NOT NULL
),

NextPurchase AS (
    SELECT
        cp1.CustomerID,
        cp1.PurchaseDate,
        MIN(cp2.PurchaseDate) AS NextPurchaseDate
    FROM CustomerPurchases cp1
    LEFT JOIN CustomerPurchases cp2
        ON cp1.CustomerID = cp2.CustomerID
        AND cp2.PurchaseDate > cp1.PurchaseDate
    GROUP BY cp1.CustomerID, cp1.PurchaseDate
),

RetentionFlags AS (
    SELECT
        CustomerID,
        PurchaseDate,
        NextPurchaseDate,
        CASE
            WHEN DATEDIFF(DAY, PurchaseDate, NextPurchaseDate) <= 90 THEN 1
            ELSE 0
        END AS IsRetained
    FROM NextPurchase
)

SELECT
    FORMAT(PurchaseDate, 'yyyy-MM') AS PurchaseMonth,
    COUNT(*) AS TotalPurchases,
    SUM(IsRetained) AS RetainedPurchases,
    COUNT(*) - SUM(IsRetained) AS ChurnedPurchases,
    ROUND(1.0 * SUM(IsRetained) / COUNT(*), 2) AS RetentionRate,
    ROUND(1 - 1.0 * SUM(IsRetained) / COUNT(*), 2) AS ChurnRate
FROM RetentionFlags
GROUP BY FORMAT(PurchaseDate, 'yyyy-MM')
ORDER BY PurchaseMonth;

