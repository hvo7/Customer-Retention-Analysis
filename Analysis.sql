USE Online_Retail;

GO


/*
After performing RFM analysis, we will now use SQL to answer the following hypotheses:

H1: One-time buyers are more likely to churn.

H2: Customers who haven’t purchased in 90+ days are unlikely to return

H3: The average days between purchases is shorter for loyal customers.

H4: Customers with high total spend are more likely to stay.

H5: Customers who previously churned are more likely to churn again.
*/


/*
 ------------------------------H1: One-time buyers are more likely to churn-------------------------------------

--I will specifically perform snapshot-based churn calculations
--First let's define a customer as "churned" if they haven't purchased at least 90 days before the final date of analysis.
-- WITH Max_Date AS (
--     SELECT 
--         MAX(CAST(InvoiceDate AS Date)) AS Analysis_Date
--     FROM dbo.Online_Retail
-- ),

-- One_Purchase AS (
--     SELECT 
--         CustomerID,
--         MAX(CAST(InvoiceDate AS DATE)) AS Most_Recent_Purchase,
--         CASE WHEN 
--             COUNT(DISTINCT InvoiceNo) = 1 THEN 1
--             ELSE 0
--             END AS One_Purchase_Buyer
--     FROM dbo.Online_Retail
--     WHERE CustomerID IS NOT NULL 
--     GROUP BY CustomerID
-- ),

-- Churn_Check AS (
--     SELECT
--         CustomerID,
--         One_Purchase_Buyer,
--         Most_Recent_Purchase,
--         DATEDIFF(DAY, Most_Recent_Purchase, Analysis_Date) AS Days_Since_Purchase,
--         CASE WHEN 
--             DATEDIFF(DAY, Most_Recent_Purchase, Analysis_Date) >= 90 THEN 1.0
--             ELSE 0.0
--         END AS Churned
--     FROM One_Purchase a
--     CROSS JOIN Max_Date b
-- )

-- SELECT
--     One_Purchase_Buyer,
--     AVG(Churned) AS Churn_Rate
-- FROM Churn_Check
-- GROUP BY One_Purchase_Buyer

/*
    Result:
    One_Purchase_Buyer          Churn_Rate
            0	                 0.231448
            1	                 0.568164

We can see that customers that have only purchased once have a higher churn rate than customers who have multiple purchases.
*/  

-----------------------H2: Customers who haven’t purchased in 90+ days are unlikely to return----------------------
/* 
Identify customers who haven't purchased in 90+ days as a proxy for churn.
This isn't definitive proof that they are lost customers but are still high-risk. 
I will need future data in order to prove whether customers who haven't purchased in 90+ days have truly churned. 

*/

-- WITH Max_Date AS (
--     SELECT 
--         MAX(CAST(InvoiceDate AS Date)) AS Analysis_Date
--     FROM dbo.Online_Retail
-- ),

-- Recent_Purchase AS (
--     SELECT 
--         CustomerID,
--         MAX(InvoiceDate) AS most_recent_purchase
--     FROM dbo.Online_Retail
--     WHERE CustomerID IS NOT NULL
--     GROUP BY CustomerID
-- )

-- SELECT 
--     a.CustomerID,
--     a.most_recent_purchase,
--     DATEDIFF(DAY, most_recent_purchase, Analysis_Date) AS Days_Since_Last_Purchase
--     FROM Recent_Purchase a
--     CROSS JOIN Max_Date
--     WHERE DATEDIFF(DAY, most_recent_purchase, Analysis_Date) >= 90
--     ORDER BY Days_Since_Last_Purchase DESC
*/

---------------------------H3: Frequent buyers are less likely to churn-------

-- WITH Max_Date AS (
--     SELECT 
--         MAX(CAST(InvoiceDate AS Date)) AS Analysis_Date
--     FROM dbo.Online_Retail
-- ),

-- Orders AS (
--     SELECT 
--         CustomerID,
--         MAX(CAST(InvoiceDate AS DATE))  AS recent_purchase,
--         COUNT(Distinct InvoiceNo) AS Num_orders
--     FROM dbo.Online_Retail
--     WHERE CustomerID IS NOT NULL 
--     GROUP BY CustomerID
-- ),

-- Churn_Check AS (
--     SELECT 
--         CustomerID,
--         DATEDIFF(DAY, recent_purchase, Analysis_Date) AS Days_Since_Purchase,
--         CASE WHEN 
--             DATEDIFF(DAY, recent_purchase, Analysis_Date) >= 90 THEN 1.0
--             ELSE 0.0
--         END AS Churned
--     FROM Orders 
--     CROSS JOIN Max_Date
-- ),

-- RFM AS (
--     SELECT 
--         CustomerID,
--         PERCENT_RANK() OVER (Order By Num_orders ASC) * 10 AS Frequency
--     FROM Orders
-- ),

-- High_Frequent_Buyers AS (
--     SELECT 
--         a.CustomerID,
--         CASE WHEN
--             Frequency >= 7 THEN 1
--             ELSE 0
--         END AS High_Frequency_Buyers
--     FROM RFM a
--     LEFT JOIN Orders b ON a.CustomerID = b.CustomerID 
-- )

-- SELECT 
--     High_Frequency_Buyers,
--     AVG(Churned) AS Avg_Churned
-- FROM Orders a
-- LEFT JOIN High_Frequent_Buyers b ON a.CustomerID = b.CustomerID
-- LEFT JOIN Churn_Check c ON a.CustomerID = c.CustomerID
-- GROUP BY High_Frequency_Buyers

/*
    Result:

    High_Frequent_Buyers        Avg_Churned
            0	                 0.420091
            1	                 0.068077

We see here that high frequency customers have signficantly  less average churn rate.
*/


------------H4: Customers with high total spend are more likely to stay.------------
-- Let's define high spenders as those with a monetary value >= 7 (from RFM analysis)

-- WITH Max_Date AS (
--     SELECT 
--         MAX(CAST(InvoiceDate AS Date)) AS Analysis_Date
--     FROM dbo.Online_Retail
-- ),

-- Orders AS (
--     SELECT 
--         CustomerID,
--         MAX(CAST(InvoiceDate AS DATE))  AS recent_purchase,
--         COUNT(Distinct InvoiceNo) AS Num_orders,
--         ROUND(SUM(Revenue),2) AS Total_Revenue
--     FROM dbo.Online_Retail
--     WHERE CustomerID IS NOT NULL AND Revenue > 0
--     GROUP BY CustomerID
-- ),

-- Churn_Check AS (
--     SELECT 
--         CustomerID,
--         DATEDIFF(DAY, recent_purchase, Analysis_Date) AS Days_Since_Purchase,
--         CASE WHEN 
--             DATEDIFF(DAY, recent_purchase, Analysis_Date) >= 90 THEN 1.0
--             ELSE 0.0
--         END AS Churned
--     FROM Orders 
--     CROSS JOIN Max_Date
-- ),

-- RFM AS (
--     SELECT 
--         CustomerID,
--         PERCENT_RANK() OVER (Order By Num_orders ASC) * 10 AS Frequency,
--         PERCENT_RANK() OVER (ORDER BY Total_Revenue ASC) * 10 AS Monetary
--     FROM Orders
-- ),

-- High_Spender AS (
--     SELECT 
--         a.CustomerID,
--         CASE WHEN
--             Monetary >= 7 THEN 1
--             ELSE 0
--         END AS High_Spender
--     FROM RFM a
--     LEFT JOIN Orders b ON a.CustomerID = b.CustomerID 
-- )

-- SELECT 
--     High_Spender,
--     AVG(Churned) AS Avg_Churned
-- FROM Orders a
-- LEFT JOIN High_Spender b ON a.CustomerID = b.CustomerID
-- LEFT JOIN Churn_Check c ON a.CustomerID = c.CustomerID
-- GROUP BY High_Spender

/*
    Result:
            High_Spender        Avg_Churned
                    0	         0.430688
                    1	         0.108378

We see here that those that are high spenders have less average churn rate.
*/








--------------H5: Customers who previously churned are more likely to churn again.----------
-- Again, define churn as inactivity for 90+ days. First, we identify whether a customer has ever churned before. Then we compare that with the final possible churn 
-- of 90+ days from our analysis_date

WITH Purchases AS (
    SELECT 
        CustomerID,
        CAST(InvoiceDate AS DATE) AS PurchaseDate,
        LAG(CAST(InvoiceDate AS DATE)) OVER (PARTITION BY CustomerID ORDER BY InvoiceDate ASC) AS Prev_Order
    FROM dbo.Online_Retail
    WHERE CustomerID IS NOT NULL
),

Date_Between_Purchases AS (
    SELECT
        CustomerID,
        PurchaseDate,
        DATEDIFF(DAY, PurchaseDate, Prev_Order) AS Days_From_Prev,
        CASE WHEN 
            DATEDIFF(DAY, Prev_Order, PurchaseDate) >= 90 THEN 1.0
            ELSE 0.0
        END AS Churn_Flag
    FROM Purchases
),

Customer_Churn AS (
    SELECT
        CustomerID,
        MAX(CAST(PurchaseDate AS DATE)) AS most_recent_purchase,
        Sum(Churn_Flag) AS Num_Churn,
        MAX(Churn_Flag) AS Prev_Churn
    FROM Date_Between_Purchases
    GROUP BY CustomerID
),

Max_Date AS (
    SELECT
        Max(InvoiceDate) AS Analysis_Date
    FROM dbo.Online_Retail
),

Recurring_Churn AS (
    SELECT 
        CustomerID,
        Prev_Churn,
        CASE WHEN
            DATEDIFF(DAY, most_recent_purchase, Analysis_Date) >= 90 THEN 1.0
            ELSE 0.0
        END AS final_churn
        FROM Customer_Churn
        CROSS JOIN Max_Date
)

SELECT 
    Prev_Churn,
    AVG(final_churn) AS Avg_Churned
FROM Recurring_Churn
GROUP BY Prev_Churn

























------------------------------------------------------------------------------------------------------------------
/*   Problems I encountered in the dataset or way it transferred


-- P1: Identified that some rows for description are more than just blank, also contains tabs, zero-width space, etc. - Reformat Description

-- Query that identified problem
SELECT DISTINCT TRIM(Description), LEN(Description) AS LEN, DATALENGTH(Description) AS Datalen
FROM Dbo.Online_Retail
WHERE Description IS NOT NULL AND LEN(Description) <> DATALENGTH(Description)

--------
Solution: 
Replace all the tabs, non-breaking space, etc. with empty space so that TRIM works 

UPDATE dbo.Online_Retail
SET Description = 
REPLACE(
    REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(TRIM(Description), CHAR(9),''), -- Remove Tabs
                    CHAR(10), ''), -- Remove Line Feed
                CHAR(13), ''), -- Remove non-breaking space
        CHAR(160), ''),-- Remove Carriage Return 
    NCHAR(8203), '') -- remove zero-width space
FROM dbo.Online_Retail
WHERE Description IS NOT NULL

*/





/*      P2: we see a big problem in the way the data transferred into mssql. it all shifted to the right by one value. 

                InvoiceNo   StockCode            Description                    Quantity         InvoiceDate     UnitPrice CustomerID            Country
     Bad Row Ex: 536381	        82567	    "AIRLINE LOUNGE	METAL SIGN"	            2	               12/1/2010        9:41	2.1	            15311,United Kingdom

-- Query that identified problem
SELECT *
FROM dbo.Online_Retail_Cleaned
WHERE TRY_CONVERT(DATETIME, [InvoiceDate]) IS NULL
  AND [InvoiceDate] IS NOT NULL
  AND LTRIM(RTRIM([InvoiceDate])) <> '';


Solution:
Replaced commas in the Description column with ";" done in excel -> retransferred the db

*/





/*         P3: Need a Revenue column that is simply Quantity * Unit Price for each order

ALTER TABLE dbo.Online_Retail
ADD Revenue AS ROUND(CAST(Quantity AS FLOAT) * CAST(UnitPrice AS FLOAT),2)

Solution: Simply add a new column for revenue.

*/


