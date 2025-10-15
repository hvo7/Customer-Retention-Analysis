USE Online_Retail;

WITH Monthly_Customer_Revenue AS
(
	SELECT
		CustomerID,
		DATEFROMPARTS(Year(InvoiceDate), Month(InvoiceDate), 1) AS Month_Year,
		SUM(Revenue) AS Monthly_Revenue
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
	GROUP BY
		CustomerID,
		DATEFROMPARTS(Year(InvoiceDate), Month(InvoiceDate), 1)
)

SELECT
	Month_Year,
	AVG(Monthly_Revenue) AS Avg_Monthly_Revenue
FROM Monthly_Customer_Revenue
GROUP BY Month_Year
ORDER BY Month_Year