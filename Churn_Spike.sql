USE Online_Retail;

WITH Orders AS 
(
	SELECT
		CustomerID,
		InvoiceNo,
		MIN(InvoiceDate) AS Purchase_Date
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND Quantity > 0
	GROUP BY 
		CustomerID,
		InvoiceNo
)

SELECT
	CustomerID,
	Purchase_Date,
	LAG(Purchase_Date, 1) OVER (PARTITION BY 
											CustomerID 
											ORDER BY Purchase_Date ASC
										) AS Prev_Purchase_Date,
	DATEDIFF(Day, 
			 LAG(Purchase_Date, 1) OVER (PARTITION BY 
											CustomerID 
											ORDER BY Purchase_Date ASC
										),
			 Purchase_Date) AS Days_Between_Purchases
FROM Orders
ORDER BY CustomerID, Purchase_Date
	