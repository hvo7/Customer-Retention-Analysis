USE Online_Retail;

WITH Last_Purchase AS
(
	SELECT
		CustomerID,
		MAX(InvoiceDate) AS Last_Purchase
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
	GROUP BY CustomerID
),

Max_Date AS
(
	SELECT
		MAX(InvoiceDate) AS Max_Date
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
),

Churn AS
(
	SELECT
		CustomerID,
		DATEDIFF(DAY, Last_Purchase, Max_Date) AS Date_From_Last,
		CASE
			WHEN DATEDIFF(DAY, Last_Purchase, Max_Date) > 86
				THEN 1
			ELSE 0
		END AS Churn_Flag
	FROM Last_Purchase
	CROSS JOIN Max_Date
),

Customer_Product AS
(
	SELECT DISTINCT
		CustomerID,
		Description AS Product
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
		AND Description IS NOT NULL
),

Customer_Product_Churn AS
(
	SELECT
		a.CustomerID,
		Product,
		Churn_Flag
	FROM Churn a
	JOIN Customer_Product b
		ON a.CustomerID = b.CustomerID
),

Avg_Churn_Rate AS
(
	SELECT
		CAST(AVG(CAST(Churn_Flag AS FLOAT)) AS DECIMAL(5,3)) AS Avg_Churn_Rate
	FROM Customer_Product_Churn
)

SELECT
	Product,
	COUNT(DISTINCT CustomerID) AS Total_Customers,
	COUNT(DISTINCT CASE WHEN Churn_Flag = 1 THEN CustomerID END) AS Churned_Customers,

	CAST 
	( 
		1.0 * COUNT(DISTINCT CASE WHEN Churn_Flag = 1 THEN CustomerID END) / 	NULLIF(COUNT(DISTINCT CustomerID),0)		
	 AS DECIMAL(5,3)
	) AS Churn_Rate,
	Avg_Churn_Rate,

	CAST 
	(
		(1.0 * COUNT(DISTINCT CASE WHEN Churn_Flag = 1 THEN CustomerID END)  / 	NULLIF(COUNT(DISTINCT CustomerID),0))
	 - Avg_Churn_Rate
	 AS DECIMAL(5,3)
	) AS Churn_Lift,

	CASE 
		WHEN CAST 
				(
					(1.0 * COUNT(DISTINCT CASE WHEN Churn_Flag = 1 THEN CustomerID END)  / 	NULLIF(COUNT(DISTINCT CustomerID),0))
				 - Avg_Churn_Rate
				 AS DECIMAL(5,3)
				) > 0 
			THEN 'Risky_Product'
		WHEN CAST 
				(
					(1.0 * COUNT(DISTINCT CASE WHEN Churn_Flag = 1 THEN CustomerID END)  / 	NULLIF(COUNT(DISTINCT CustomerID),0))
				 - Avg_Churn_Rate
				 AS DECIMAL(5,3)
				) < 0 
			THEN 'Hero_Product'
		ELSE 'Neutral'
	END AS Product_Label
				
FROM Customer_Product_Churn
CROSS JOIN Avg_Churn_Rate
GROUP BY Product, Avg_Churn_Rate
HAVING COUNT(DISTINCT CustomerID) >= 30 -- Remove edge cases that have small customer sample size
ORDER BY Churn_Lift DESC