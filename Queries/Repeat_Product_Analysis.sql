USE Online_Retail;

-- Determining Repeat Rate
/*
WITH First_Orders AS 
(
	SELECT
		CustomerID,
		Description,
		InvoiceDate,
		MIN(InvoiceDate) OVER (PARTITION BY CustomerID, Description) AS First_Purchase
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL AND Description IS NOT NULL
),

Unique_Customer AS 
(
	SELECT
		Description,
		COUNT(DISTINCT(CustomerID)) AS Unique_Customers
	FROM dbo.Online_Retail_Analysis
	WHERE Description IS NOT NULL AND CustomerID IS NOT NULL
	GROUP BY Description
),

Repeat_Flag AS 
(
	SELECT 
		b.CustomerID,
		b.Description,
		b.InvoiceDate,
		First_Purchase,
		CASE WHEN 
			b.InvoiceDate > First_Purchase 
			THEN 1 ELSE 0 
			END AS Repeat_Flag
	FROM First_Orders a 
	RIGHT JOIN dbo.Online_Retail_Analysis b
	ON a.CustomerID = b.CustomerID 
	AND a.Description = b.Description
	AND a.InvoiceDate = b.InvoiceDate
	WHERE b.Description IS NOT NULL AND b.CustomerID IS NOT NULL
),

Repeat_Customer AS 
(
	SELECT 
		Description,
		COUNT
		(
			DISTINCT CASE WHEN Repeat_Flag = 1 THEN CustomerID END
		) AS Repeat_Customers
	FROM Repeat_Flag
	GROUP BY Description
),

Repeat_Rate AS 
(	
SELECT
		b.Description,
		Repeat_Customers,
		Unique_Customers,
		ROUND((CAST(Repeat_Customers AS FLOAT)/CAST(Unique_Customers AS FLOAT)), 4) AS Repeat_Rate,
		CASE WHEN 
			(ROUND((CAST(Repeat_Customers AS FLOAT)/CAST(Unique_Customers AS FLOAT)),2) > 0)
			THEN 1 ELSE 0
		END AS Repeat_Product_Flag
	FROM Repeat_Customer a
	FULL JOIN Unique_Customer b
	ON a.Description = b.Description
)


SELECT
	Repeat_Product_Flag,
	AVG(Revenue) AS Avg_Revenue
FROM dbo.Online_Retail_Analysis a
LEFT JOIN Repeat_Rate b
ON a.Description = b.Description
WHERE a.Description IS NOT NULL AND CustomerID IS NOT NULL
GROUP BY Repeat_Product_Flag
*/

WITH First_Orders AS 
(
	SELECT
		CustomerID,
		Description,
		InvoiceDate,
		Revenue,
		MIN(InvoiceDate) OVER (PARTITION BY CustomerID, Description) AS First_Purchase
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL AND Description IS NOT NULL
),

Repeat_Flag AS 
(
	SELECT 
		b.CustomerID,
		b.Description,
		b.InvoiceDate,
		b.Revenue,
		First_Purchase,
		CASE WHEN 
			b.InvoiceDate > First_Purchase 
			THEN 1 ELSE 0 
			END AS Repeat_Flag
	FROM First_Orders a 
	RIGHT JOIN dbo.Online_Retail_Analysis b
	ON a.CustomerID = b.CustomerID 
	AND a.Description = b.Description
	AND a.InvoiceDate = b.InvoiceDate
	WHERE b.Description IS NOT NULL AND b.CustomerID IS NOT NULL
),

Repeat_Customer_Flag AS 
(
	SELECT
		CustomerID,
		MAX(Repeat_Flag) AS Repeat_Customer_Flag
	FROM Repeat_Flag
	GROUP BY CustomerID
)

SELECT
	Description,
	SUM(Revenue)
FROM Repeat_Flag a
INNER JOIN Repeat_Customer_Flag b
WHERE Repeat_Customer_Flag = 1
GROUP BY Description

