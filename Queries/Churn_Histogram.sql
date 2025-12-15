-- Objective: Determine how long 80% of repeat purchases go before churning (Define the churn window)
-- Conclusion: 80% of repeat purchases occur before 70 days from the previous purchase

USE Online_Retail;

WITH Purchases AS 
(
	SELECT
	DISTINCT
		CustomerID,
		CAST(InvoiceDate AS DATE) AS InvoiceDate
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
	GROUP BY
		CustomerID,
		CAST(InvoiceDate AS DATE)
),

Gaps AS
(
	SELECT
		CustomerID,
		InvoiceDate,
		LAG(InvoiceDate) OVER (PARTITION BY CustomerID ORDER BY InvoiceDate ASC) AS Prev_Purchase,
		DATEDIFF(DAY, LAG(InvoiceDate) OVER (PARTITION BY CustomerID ORDER BY InvoiceDate ASC), InvoiceDate) AS Gap
	FROM Purchases
)

SELECT 
	Gap,
	COUNT(*) AS Count
FROM Gaps  
WHERE Gap IS NOT NULL
GROUP BY Gap
ORDER BY Gap ASC
