-- Objective: Establish the top 50 customers based on churn score

USE Online_Retail;

WITH Purchases AS
(
	SELECT
		CustomerID,
		CAST(InvoiceDate AS DATE) AS InvoiceDate,
		COUNT(CAST(InvoiceDate AS DATE)) OVER (PARTITION BY CustomerID) AS Num_Purchase_Dates
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
	GROUP BY CustomerID, CAST(InvoiceDate AS DATE)
),

Next_Date AS 
(
	SELECT
		CustomerID,
		InvoiceDate,
		Num_Purchase_Dates,
		LEAD(InvoiceDate) OVER (PARTITION BY CustomerID ORDER BY InvoiceDate ASC) AS Next_Date
	FROM Purchases
),

Gaps AS
(
	SELECT
		CustomerID,
		InvoiceDate,
		Num_Purchase_Dates,
		DATEDIFF(DAY, InvoiceDate, Next_Date) AS Days_From_Next
	FROM Next_Date
	WHERE Next_Date IS NOT NULL
		AND DATEDIFF(DAY, InvoiceDate, Next_Date) > 0
		AND NOT (DATEDIFF(DAY, InvoiceDate, Next_Date) = 1 AND Num_Purchase_Dates = 2)
),

Personal_Churn AS
(
	SELECT DISTINCT
		CustomerID,
		Num_Purchase_Dates,
		PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY Days_From_Next ASC) OVER (PARTITION BY CustomerID) AS Personal_Churn_Window
	FROM Gaps
),

Final_Gap AS
(
	SELECT
		CustomerID,
		CAST(DATEDIFF(DAY, MAX(InvoiceDate), (SELECT MAX(InvoiceDate) FROM Purchases)) AS FLOAT) AS Days_From_End
	FROM Purchases
	GROUP BY CustomerID
),

Churn_Score AS
(
	SELECT
		a.CustomerID,
		Num_Purchase_Dates,
		Days_From_End,
		CAST(Personal_Churn_Window AS FLOAT) AS Personal_Churn_Window,
		CASE
			WHEN (Num_Purchase_Dates = 2) 
				THEN Days_From_End / 70 -- Use Global Churn Window 
			ELSE
				Days_From_End / CAST(Personal_Churn_Window AS FLOAT) 
			END AS Churn_Risk_Score
	FROM Personal_Churn a
	JOIN Final_Gap b
		ON a.CustomerID = b.CustomerID
	WHERE a.Personal_Churn_Window > 0
)

SELECT
*
FROM Churn_Score a
ORDER BY Churn_Risk_Score DESC