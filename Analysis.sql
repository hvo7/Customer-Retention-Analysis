USE Online_Retail;

GO



/*
After performing RFM analysis, we will now use SQL to answer the following hypotheses:

H1: Customers who buy multiple product categories are more likely to return.

H2: Customers who make their first purchase in December have lower retention.

H3: The average days between purchases is shorter for loyal customers.

H4: High-frequency customers tend to purchase fewer items per order but more often.

H5: Customers in Segment X (e.g., RFM 555) increased spending after the campaign.

H6: Customers who were emailed are more likely to return within 30 days.

H7: Customers who received a discount coupon have higher frequency post-campaign.

H8: Customers who haven’t purchased in 90+ days are unlikely to return.

H9: Customers with only 1 purchase have a 70%+ chance of not returning.

H10: Customers with low Quantity per Invoice are more likely to churn.
*/



/*
 ------------------------------H1: Customers who buy multiple product categories are more likely to return.-------------------------------------



Define retention: Customer has made another purchase within 1 month (30 days) from their original purchase
Compare the retention of customers with multiple products vs. without multiple products
Multiple products definition: >= 16 distinct products

-- Determine how many distinct products the bottom 30% of customers have. 
-- Customers ranked by how many distinct products they have - Ex: Top 99% has 1000 products (most). Bottom 1% has 1 distinct product

-- WITH Product_Counts AS (
-- SELECT 
--     CustomerID, 
--     COUNT(DISTINCT(Description)) AS Unique_Products
-- FROM dbo.Online_Retail
-- WHERE Description IS NOT NULL AND LEN(TRIM(Description)) > 0 -- Remove empty strings and nulls
-- GROUP BY CustomerID
-- ),
-- Rank_Customers AS (
--     SELECT *,
--         Percent_Rank() OVER (ORDER BY Unique_Products ASC ) AS Percent_Rank
--     FROM Product_Counts
-- )
-- SELECT MAX(Unique_Products) AS Bottom30
-- FROM Rank_Customers
-- WHERE Percent_Rank <= 0.3;



-- Multiple products definition: >= 16 distinct products
--Include multiple products column
WITH Product_Counts AS (
    SELECT 
        CustomerID, 
        COUNT(DISTINCT(Description)) AS Unique_Products
    FROM dbo.Online_Retail
    WHERE Description IS NOT NULL AND LEN(TRIM(Description)) > 0 AND CustomerID IS NOT NULL-- Remove empty strings and nulls
    GROUP BY CustomerID
),

MultipleProduct AS (
    SELECT
        CustomerID,
        CASE WHEN 
            Unique_Products >= 16 THEN 1
            ELSE 0
        END AS Multiple_Product
    FROM Product_Counts
),

-- Include Retention
PurchaseSpan AS (
    SELECT 
        CustomerID,
        MAX(InvoiceDate) AS first_purchase,
        MIN(InvoiceDate) AS recent_purchase
    FROM dbo.Online_Retail
    WHERE Description IS NOT NULL AND LEN(TRIM(Description)) > 0 AND CustomerID IS NOT NULL
    GROUP BY CustomerID
),

Retained AS (
    SELECT 
        CustomerID,
        CASE WHEN
            DATEDIFF(day,first_purchase, recent_purchase) >= 30 THEN 1
            ELSE 0
        END AS Retained
    FROM PurchaseSpan
),

-- Combine into one query:
-- CustomerID with 2 binary columns: 
-- 1) label 1 if considered multiple product customer (>=16) 
-- 2) label 1 if considered retained (purchase within 30 days from initial)

Combined AS (
    SELECT
        T.CustomerID,
        a.Multiple_Product,
        b.Retained
    FROM dbo.Online_Retail T
    LEFT JOIN MultipleProduct a ON T.CustomerID = a.CustomerID
    LEFT JOIN Retained b ON T.CustomerID = b.CustomerID
)

SELECT
    Multiple_Product,
    AVG(CAST(Retained AS FLOAT)) AS Retention_Rate
FROM Combined
GROUP BY Multiple_Product

    /*Result:

    Multiple _Product         Retention Rate
        0	                0.10345541071798055
        1	                0.4888117183968118

    We see here that customers who order multiple products indeed have a higher retention rate.
    */

*/

----------------------------------------------------------------------- H2: Customers who make their first purchase in December have lower retention.
-- The idea behind this hypothesis is that December shopped are seasonal
-- Like before, a retained customer retained has repurchased 30+ days after their initial purchase.

/*
WITH Purchases AS (
    SELECT 
        CustomerID,
        MIN(InvoiceDate) AS First_Purchase,
        MAX(InvoiceDate) AS Last_Purchase
    FROM dbo.Online_Retail
    GROUP BY CustomerID
),

Retention AS (
    SELECT 
        CustomerID,
        CASE WHEN 
            DATEDIFF(day, First_Purchase, Last_Purchase) >= 30 THEN 1
            ELSE 0
        END AS Retained,

        CASE WHEN
            Month(First_Purchase) = 12 AND Year(First_Purchase) = 2010 THEN 1
            ELSE 0
        END AS Dec_First_Purchase
    FROM Purchases
    WHERE NOT (Month(First_Purchase) = 12 AND Year(First_Purchase) = 2011) --We dont have Jan 2012, to correctly identify 1 month retention, so we can only use Dec 2010
)

SELECT 
    Dec_First_Purchase,
    AVG(CAST(Retained AS FLOAT)) AS Retention_Rate
FROM Retention 
GROUP BY Dec_First_Purchase
*/


/*
Result:
Dec First Purchase             Retention Rate
        0	                  0.2898916057474162
        1	                  0.5616438356164384

We see here that those who actually purchase in december have a higher retention rate than those who do not. This could mean that the products purchased may 
not be correlated speficially with seasonality (Christmas or gift-giving)
*/

-----------------------------------------------H3: The average days between purchases is shorter for loyal customers.
/*
Using RFM analysis, I will define a "loyal customer" as someone who falls under the top 70% of Recency and top 30% of Frequency. 
Although I already did RFM analysis in excel, we wil use SQL as well to do this.

* Encoutered issue where SQL interepreted InvoiceDate as dd/mm/yyyy rather than mm/dd/yyyy, which led to 8/2/2011 being more recent than 12/7/2011 - Incorrect.
Problem initially identified when comparing RFM analysis on SQL with RFM on Excel.

Fixed by Casting InvoiceDate explicitly as DATE. 


*/

WITH Orders AS (
    SELECT 
        CustomerID,
        MIN(CAST(InvoiceDate AS DATE)) AS first_purchase,
        MAX(CAST(InvoiceDate AS DATE))  AS recent_purchase,
        COUNT(DISTINCT InvoiceDate) AS Num_orders
    FROM dbo.Online_Retail
    WHERE CustomerID IS NOT NULL 
    GROUP BY CustomerID
),

RFM AS (
    SELECT 
        CustomerID,
        PERCENT_RANK() OVER (ORDER BY recent_purchase ASC) * 10 AS Recency,
        PERCENT_RANK() OVER (Order By Num_orders ASC) * 10 AS Frequency
    FROM Orders
),

Loyalty AS (
    SELECT 
    O.CustomerID,
    first_purchase,
    recent_purchase,
    Num_orders,
    CASE WHEN 
        Recency >= 7 AND Frequency >= 3 THEN 1
        ELSE 0
    END AS Loyalty
FROM Orders O 
LEFT JOIN RFM R ON O.CustomerID = R.CustomerID
)

SELECT 
    Loyalty,
    AVG(DATEDIFF(day, first_purchase, recent_purchase) * 1.0 / NULLIF(Num_orders - 1,0)) AS AvgDayBetweenPurchase
FROM Loyalty
GROUP BY Loyalty  


/*
Result:
Loyalty - Binary col of whether loyal customer or not. I have demonstrated that H3 is true - Loyal customers have fewer average days between purchases.

Loyalty     AvgDayBetweenPurchases
0	             65.281286628245
1	             53.301462446130

*/


------------------------------------------








-------------------------------------------------------------------------------------------------------------------
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

/* P2: we see a big problem in the way the data transferred into mssql. it all shifted to the right by one value. 
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