USE Online_Retail;

-- Determining Repeat Rate at the product level

WITH First_Orders AS 
(
	SELECT
		Description,
		InvoiceDate,
		CustomerID,
		DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Month_Year,
		MIN(InvoiceDate) OVER (PARTITION BY CustomerID, Description) AS First_Purchase
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL 
		AND Description IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
),

Month_Buckets AS
(
	SELECT 
		DISTINCT Description, DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Month_Year
	FROM dbo.Online_Retail_Analysis
	WHERE Description IS NOT NULL
),


Monthly_Customers AS
(
	SELECT
		Description,
		Month_Year,
		CustomerID
	FROM First_Orders
	GROUP BY CustomerID, Description, Month_Year
),


Prev_Buyers AS 
(
	SELECT 
		a.Description,
		a.Month_Year,
		b.CustomerID AS Previous_Customer
	FROM Month_Buckets a
	JOIN First_Orders b
		ON a.Description = b.Description
		AND a.Month_Year > b.First_Purchase
),


Repeat_Buyers AS
(
	SELECT
		a.Description,
		a.Month_Year,
		a.CustomerID AS Repeat_Customer
	FROM Monthly_Customers a
	JOIN First_Orders b
		ON a.Description = b.Description
		AND a.CustomerID = b.CustomerID
		AND a.Month_Year > First_Purchase
),

Returner_Rates AS 
(
	SELECT 
		a.Description,
		a.Month_Year,
		COUNT(DISTINCT(b.Previous_Customer)) AS Previous_Customers,
		COUNT(DISTINCT(c.Repeat_Customer)) AS Repeat_Customers,
		COALESCE(
				CAST(												-- Numerator is Repeat_Customers
						COUNT(
								DISTINCT(c.Repeat_Customer)
					) AS FLOAT) 
					 
			
				/ NULLIF(COUNT(DISTINCT(b.Previous_Customer)),0.0)	-- Denominator is Previous Customers

			,0.0) AS Returner_Rate
	FROM Month_Buckets a
	LEFT JOIN Prev_Buyers b
		ON a.Description = b.Description
		AND a.Month_Year = b.Month_Year
	LEFT JOIN Repeat_Buyers c
		ON a.Description = c.Description
		AND a.Month_Year = c.Month_Year
	GROUP BY a.Description, a.Month_Year
),

Returner_Rate_Delta AS
(
	SELECT
		Description, 
		Month_Year,
		ROUND(Returner_Rate - LAG(Returner_Rate, 1) OVER (PARTITION BY Description ORDER BY Month_Year),4) AS Returner_Rate_Delta
	FROM Returner_Rates
)

SELECT
	Description,
	AVG(Returner_Rate_Delta) AS Avg_Returner_Rate_Delta
FROM Returner_Rate_Delta
GROUP BY Description
ORDER BY Description