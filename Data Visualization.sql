USE Online_Retail

GO

WITH Recent_Purchase AS (
    SELECT
        CustomerID,
        CAST(InvoiceDate AS DATE) AS Purchase_Date,
        MAX(CAST(InvoiceDate AS DATE)) OVER (PARTITION BY CustomerID) AS Most_Recent_Purchase
    FROM dbo.Online_Retail
    WHERE CustomerID IS NOT NULL
),

Max_Date AS (
    SELECT
        Max(InvoiceDate) AS Analysis_Date
    FROM dbo.Online_Retail
),

Lost_Customers AS (
    SELECT  
        CustomerID,
        Most_Recent_Purchase,
        DATEPART(Year, Purchase_Date) AS Year,
        DATEPART(Month, Purchase_Date) AS Month,
        CASE WHEN
            DATEDIFF(DAY, Most_Recent_Purchase, Analysis_Date) >= 90 THEN 1
            ELSE 0
        END AS Lost
    FROM Recent_Purchase 
    CROSS JOIN Max_Date
)

SELECT 
    Year,
    Month,
    COUNT(DISTINCT CustomerID) AS Num_Lost_Customers
FROM Lost_Customers
GROUP BY Year, Month
Order By Year, Month
