USE Online_Retail;

WITH Customer_Order_Months AS 
(
	SELECT
		CustomerID,
		CAST(DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate),1) AS DATETIME) AS Month_Year,
		ROUND(SUM(Revenue),2) AS Monthly_Revenue
	FROM dbo.Online_Retail_Analysis
	WHERE Year(InvoiceDate) = 2011 
		AND CustomerID IS NOT NULL
		AND CUSTOMERID = 12347
	GROUP BY 
		CustomerID,
		YEAR(InvoiceDate),
		MONTH(InvoiceDate)
),

Averages AS 
(
	SELECT
		CustomerID,
		Month_Year,
		Monthly_Revenue,
		AVG(Monthly_Revenue) OVER (PARTITION BY 
									CustomerID,
									CASE WHEN MONTH(Month_Year) <= 6 THEN 1 ELSE 2 END						  						  
								  ) AS Avg_Revenue,
		AVG(CAST(Month_Year AS FLOAT)) OVER (PARTITION BY CustomerID) AS Avg_Date
	FROM Customer_Order_Months
),

Diffs AS 
(
	SELECT
		CustomerID,
		Month_Year,
		CAST(Month_Year AS FLOAT) - Avg_Date AS Date_Diff,
		Monthly_Revenue - Avg_Revenue AS Revenue_Diff
	FROM Averages
),

Risk_Groups AS 
(
	SELECT 
		CustomerID,
		RFM_Score,
		CASE 
			WHEN (CAST(Recency AS INT) + CAST(Frequency AS INT)) IN (2,3,4) THEN 'High_Risk'
			WHEN (CAST(Recency AS INT) + CAST(Frequency AS INT)) IN (9,10) THEN 'Low_Risk'
			ELSE 'Medium_Risk'
		END AS Risk_Group
	FROM dbo.RFM_Analysis
)

SELECT
		a.CustomerID,
		COALESCE
		(
			SUM(Date_Diff * Revenue_Diff)  /
			NULLIF
			(
				SQRT
				(
					SUM(POWER(Date_Diff,2)) * SUM (POWER(Revenue_Diff,2))
				)
			,0)
		,0)	AS Coefficient,
		Risk_Group
FROM Diffs a
LEFT JOIN Risk_Groups b
ON a.CustomerID = b.CustomerID
WHERE Risk_Group = 'Low_Risk'
GROUP BY a.CustomerID, b.Risk_Group
ORDER BY Coefficient DESC
