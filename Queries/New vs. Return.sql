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
	COUNT(DISTINCT(CustomerID)) AS New_Customers
FROM First_Purchases
GROUP BY First_Purchase
),

Return_Buyers AS
(
	SELECT
		a.Month_Year,
		COUNT(DISTINCT(CASE WHEN Month_Year > First_Purchase THEN a.CustomerID END)) AS Return_Cust
	FROM Orders a
	LEFT JOIN First_Purchases b
		ON a.CustomerID = b.CustomerID
	GROUP By Month_Year
)

SELECT
	Month_Year, a.New_Customers, b.Return_Cust
FROM First_Buyers a
JOIN Return_Buyers b
	ON a.First_Purchase = b.Month_Year