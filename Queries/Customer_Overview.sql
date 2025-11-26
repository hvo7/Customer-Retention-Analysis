USE Online_Retail;

WITH Purchases AS
(
	SELECT
		InvoiceNo,
		CAST(InvoiceDate AS DATE) AS InvoiceDate,
		SUM(Revenue) AS Total_Revenue
	FROM dbo.Online_Retail_Analysis
	WHERE InvoiceNo NOT LIKE '%C%'
	GROUP BY InvoiceNo, CAST(InvoiceDate AS DATE)

)

SELECT
	--COUNT(DISTINCT CustomerID) AS Total_Customers
	--ROUND(SUM(Revenue),2) AS Total_Revenue
	SUM(Total_Revenue) AS Overall_Revenue
	--COUNT(InvoiceNo) AS Total_Orders
FROM Purchases