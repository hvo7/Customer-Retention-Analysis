USE Online_Retail;

SELECT
	COUNT(DISTINCT CustomerID) AS Total_Customers
FROM dbo.Online_Retail_Analysis
WHERE CustomerID IS NOT NULL
	AND InvoiceNo NOT LIKE '%C%'