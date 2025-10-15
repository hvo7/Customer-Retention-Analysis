USE Online_Retail;

WITH High_Monetary AS 
(
	SELECT
		CustomerID,
		Monetary
	FROM dbo.RFM_Analysis
	WHERE Monetary = 5
),

Counts AS
(
	SELECT
		CustomerID,
		YEAR(InvoiceDate) AS OrderYear,
		CASE WHEN MONTH(InvoiceDate) <= 6 THEN 1 ELSE 2 END AS Half, 
		COUNT(DISTINCT InvoiceNo) AS Orders
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL 
		AND Year(InvoiceDate) = 2011
		AND InvoiceNo NOT LIKE 'C%'
	GROUP BY
		CustomerID,
		YEAR(InvoiceDate),
		CASE WHEN MONTH(InvoiceDate) <= 6 THEN 1 ELSE 2 END
),

Diff_Orders AS 
(
	SELECT
		a.CustomerID,
		SUM(CASE WHEN Half = 1 THEN Orders ELSE 0 END) AS H1_Orders,
		SUM(CASE WHEN Half = 2 THEN Orders ELSE 0 END) AS H2_Orders,
		SUM(CASE WHEN Half = 2 THEN Orders ELSE 0 END) - SUM(CASE WHEN Half = 1 THEN Orders ELSE 0 END) AS Diff_Orders
	FROM Counts a
	INNER JOIN High_Monetary b
	ON a.CustomerID = b.CustomerID
	GROUP BY 
		a.CustomerID,
		OrderYear
)

SELECT
	CustomerID,
	5 AS Monetary,
	H1_Orders,
	H2_Orders,
	Diff_Orders
FROM Diff_Orders
WHERE Diff_Orders < 0
ORDER BY Diff_Orders, CustomerID