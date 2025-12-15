-- Objective: Perform cohort analysis to discover how monthly cohorts perform and how retention and churn behaviors change over time

USE Online_Retail;


WITH Orders AS 
(
	SELECT
		CustomerID,
		DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Month_Year
	FROM dbo.Online_Retail_Analysis
	WHERE InvoiceNo NOT LIKE '%C%'
		AND CustomerID IS NOT NULL
	GROUP BY CustomerID, YEAR(InvoiceDate), MONTH(InvoiceDate)
),

First_Purchases AS 
(
	SELECT
		CustomerID,
		Month_Year,
		MIN(Month_Year) OVER (PARTITION BY CustomerID) AS Cohort_Month
	FROM Orders
)

SELECT
	Cohort_Month,
	Month_Year,
	COUNT(DISTINCT(CustomerID)) AS Num_Cust
FROM First_Purchases
GROUP BY Cohort_Month, Month_Year
ORDER BY Cohort_Month, Month_Year