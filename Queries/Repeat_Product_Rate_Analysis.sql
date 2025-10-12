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

Monthly_Customers AS
(
	SELECT
		Description,
		Month_Year,
		CustomerID
	FROM First_Orders
	GROUP BY CustomerID, Description, Month_Year
)

SELECT *
	--a.Description,
	--COUNT(DISTINCT(b.CustomerID)) AS Unique_Customers
FROM Monthly_Customers a
JOIN Monthly_Customers b
	ON a.Description = b.Description
	AND b.Month_Year <= a.Month_Year
--GROUP BY b.Description, b.Month_Year

/*
--Unique_Customer AS 
--(
	SELECT
		Description,
		Month_Year,
		COUNT(DISTINCT(CustomerID)) OVER (
										   PARTITION BY Description 
										   ORDER BY InvoiceDate ASC 
										   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
										 ) AS Unique_Customers
	FROM First_Orders
	WHERE Description IS NOT NULL AND CustomerID IS NOT NULL
	ORDER BY Description, Month_Year










), 

Repeat_Flag AS 
(
	SELECT 
		b.CustomerID,
		b.Description,
		b.InvoiceDate,
		a.Month_Year,
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
)

-- Repeat_Customer AS 
--(
	SELECT 
		Description,
		Month_Year,
		COUNT
		(
			DISTINCT CASE WHEN Repeat_Flag = 1 THEN CustomerID END
		) AS Repeat_Customers
	FROM Repeat_Flag
	GROUP BY Description, Month_Year
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