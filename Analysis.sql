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
 H1: Customers who buy multiple product categories are more likely to return.
Define retention: Customer has made another purchase within 1 month (30 days) from their original purchase
Compare the retention of customers with multiple products vs. without multiple products
Multiple products definition: >= 16 distinct products
*/

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

WITH Product_Counts AS (
    SELECT 
        CustomerID, 
        COUNT(DISTINCT(Description)) AS Unique_Products
    FROM dbo.Online_Retail
    WHERE Description IS NOT NULL AND LEN(TRIM(Description)) > 0 AND CustomerID IS NOT NULL-- Remove empty strings and nulls
    GROUP BY CustomerID
),
Retention AS (
    SELECT 
        CustomerID,
        MAX(InvoiceDate) AS first_purchase,
        MIN(InvoiceDate) AS recent_purchase
    FROM dbo.Online_Retail
    WHERE Description IS NOT NULL AND LEN(TRIM(Description)) > 0 AND CustomerID IS NOT NULL
)

SELECT 
    CustomerID,
    CASE WHEN 
        DATEDIFF(day, MIN(InvoiceDate), MAX(InvoiceDate)) >= 30 THEN 1
        ELSE 0
    END AS Retention,
    CASE WHEN
        Unique_Products >= 16 THEN 1
        ELSE 0
    END AS Multiple_Product

FROM Product_Counts

















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