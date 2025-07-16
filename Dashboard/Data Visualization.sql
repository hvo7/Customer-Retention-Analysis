USE Online_Retail;
GO

-- WITH CustomerPurchases AS (
--     SELECT
--         CustomerID,
--         CAST(InvoiceDate AS DATE) AS PurchaseDate
--     FROM dbo.Online_Retail
--     WHERE CustomerID IS NOT NULL
-- ),

-- NextPurchase AS (
--     SELECT
--         cp1.CustomerID,
--         cp1.PurchaseDate,
--         MIN(cp2.PurchaseDate) AS NextPurchaseDate
--     FROM CustomerPurchases cp1
--     LEFT JOIN CustomerPurchases cp2
--         ON cp1.CustomerID = cp2.CustomerID
--         AND cp2.PurchaseDate > cp1.PurchaseDate
--     GROUP BY cp1.CustomerID, cp1.PurchaseDate
-- ),

-- RetentionFlags AS (
--     SELECT
--         CustomerID,
--         PurchaseDate,
--         NextPurchaseDate,
--         CASE
--             WHEN DATEDIFF(DAY, PurchaseDate, NextPurchaseDate) <= 90 THEN 1
--             ELSE 0
--         END AS IsRetained
--     FROM NextPurchase
-- )

-- SELECT
--     FORMAT(PurchaseDate, 'yyyy-MM') AS PurchaseMonth,
--     COUNT(*) AS TotalPurchases,
--     SUM(IsRetained) AS RetainedPurchases,
--     COUNT(*) - SUM(IsRetained) AS ChurnedPurchases,
--     ROUND(1.0 * SUM(IsRetained) / COUNT(*), 2) AS RetentionRate,
--     ROUND(1 - 1.0 * SUM(IsRetained) / COUNT(*), 2) AS ChurnRate
-- FROM RetentionFlags
-- GROUP BY FORMAT(PurchaseDate, 'yyyy-MM')
-- ORDER BY PurchaseMonth;


-- WITH First_Purchase AS (
--     SELECT
--         CustomerID,
--         Min(CAST(InvoiceDate AS DATE)) AS First_Purchase_Date
--     FROM dbo.Online_Retail
--     WHERE CustomerID IS NOT NULL
--     GROUP BY CustomerID
-- ),

-- First_Purchase_Flag AS (
--     SELECT
--     a.CustomerID,
--     CAST(a.InvoiceDate AS DATE) AS InvoiceDate,
--     First_Purchase_Date,
--     CASE WHEN   
--         CAST(a.InvoiceDate AS DATE) = First_Purchase_Date THEN 1 
--         ELSE 0
--     END AS First_Purchase_Flag
--     FROM dbo.Online_Retail a
--     Join First_Purchase b ON a.CustomerID = b.CustomerID
-- )

-- SELECT 
--     FORMAT(InvoiceDate, 'yyyy-MM') AS PurchaseMonth,
--     COUNT(DISTINCT CustomerID) AS TotalCustomers,
--     COUNT(DISTINCT CASE WHEN First_Purchase_Flag = 1 THEN CustomerID END) AS NewCustomers
-- FROM First_Purchase_Flag
-- GROUP BY FORMAT(InvoiceDate, 'yyyy-MM')
-- ORDER BY PurchaseMonth


WITH Max_Date AS (
    SELECT 
        MAX(CAST(InvoiceDate AS Date)) AS Analysis_Date
    FROM dbo.Online_Retail
),

Orders AS (
    SELECT 
        CustomerID,
        MAX(CAST(InvoiceDate AS DATE))  AS recent_purchase,
        COUNT(Distinct InvoiceNo) AS Num_orders,
        ROUND(SUM(Revenue),2) AS Total_Revenue
    FROM dbo.Online_Retail
    WHERE CustomerID IS NOT NULL AND Revenue > 0
    GROUP BY CustomerID
),

RFM AS (
    SELECT 
        CustomerID,
        PERCENT_RANK() OVER (Order By Num_orders ASC) * 10 AS Frequency,
        PERCENT_RANK() OVER (ORDER BY Total_Revenue ASC) * 10 AS Monetary
    FROM Orders
)