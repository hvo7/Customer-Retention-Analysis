-- This file helps to validate that what I am seeing in Tableau is factually accurate to the data I am using.
USE Online_Retail;

GO

-- SELECT TOP 10
-- CustomerID,
-- COUNT(DISTINCT(InvoiceNo)) AS NumOrder
-- FROM Online_Retail_Cleaned
-- GROUP BY CustomerID
-- ORDER BY NumOrder DESC

SELECT COUNT(DISTINCT(InvoiceNo))
FROM Online_Retail_Cleaned
WHERE CustomerID = 14646