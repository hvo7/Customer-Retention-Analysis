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
		MIN(Month_Year) AS First_Purchase
	FROM Orders
	GROUP BY CustomerID
),

First_Buyers AS
(
SELECT
	First_Purchase,
	COUNT(DISTINCT(CustomerID)) AS Num_Customers
FROM First_Purchases
GROUP BY First_Purchase
)

SELECT *
FROM First_Buyers
ORDER BY First_Purchase