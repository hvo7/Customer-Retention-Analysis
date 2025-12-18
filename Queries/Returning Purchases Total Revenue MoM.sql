-- Objective: Give the total revenue MoM of returning purchases

USE Online_Retail;

WITH Orders AS 
(
	SELECT
		CustomerID,
		CAST(InvoiceDate AS DATE) AS InvoiceDate,
		SUM(Revenue) AS Order_Revenue
	FROM dbo.Online_Retail_Analysis
	WHERE InvoiceNo NOT LIKE '%C%'
		AND CustomerID IS NOT NULL
	GROUP BY 
		CustomerID,
		CAST(InvoiceDate AS DATE)
),

First_Purchases AS 
(
	SELECT
		CustomerID,
		MIN(InvoiceDate) AS First_Purchase
	FROM Orders
	GROUP BY
		CustomerID
),

Repeat_Orders AS
(
	SELECT
		a.CustomerID,
		a.InvoiceDate,
		a.Order_Revenue,
		CASE 
			WHEN a.InvoiceDate > b.First_Purchase
				THEN 1
			ELSE 0
		END AS Repeat_Flag -- Flag whether an order is purchased from a repeat or new purchaser. 1 = Repeat, 0 = New
	FROM Orders a
	JOIN First_Purchases b
		ON a.CustomerID = b.CustomerID
)

SELECT 
	DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Month_Year,
	ROUND(SUM(Order_Revenue),2) AS Total_Revenue
FROM Repeat_Orders
WHERE Repeat_Flag = 1
GROUP BY 
	YEAR(InvoiceDate),
	MONTH(InvoiceDate)
ORDER BY
	YEAR(InvoiceDate),
	MONTH(InvoiceDate)