USE Online_Retail;

WITH Orders AS
(
	SELECT
		CustomerID,
		InvoiceDate,
		Revenue
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL	
		AND InvoiceNo NOT LIKE '%C%'
	GROUP BY CustomerID, InvoiceDate, Revenue
),

RFM AS
(
	SELECT
		CustomerID,
		MAX(InvoiceDate) AS Recent_Purchase,
		COUNT(DISTINCT(
						DATEFROMPARTS(YEAR(InvoiceDate), Month(InvoiceDate), DAY(InvoiceDate))
					   )
			  ) AS Num_Orders,
		ROUND(SUM(Revenue),2) AS Total_Revenue
	FROM Orders
	GROUP BY CustomerID
),

Scores AS 
(
SELECT 
	CustomerID,
	Recent_Purchase,
	Num_Orders,
	Total_Revenue,
	NTILE(4) OVER (ORDER BY Recent_Purchase DESC) AS Recency,
	NTILE(4) OVER (ORDER BY Num_Orders DESC) AS Frequency,
	NTILE(4) OVER (ORDER BY Total_Revenue DESC) AS Monetary
FROM RFM 
)

SELECT
	Num_Orders,
	Frequency
FROM Scores
ORDER  BY Num_Orders DESC