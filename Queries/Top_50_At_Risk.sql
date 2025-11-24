USE Online_Retail;

WITH Purchases AS
(
	SELECT
		CustomerID,
		InvoiceNo,
		MIN(InvoiceDate) AS InvoiceDate
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
	GROUP BY CustomerID, InvoiceNo
)

SELECT
	*
FROM Purchases