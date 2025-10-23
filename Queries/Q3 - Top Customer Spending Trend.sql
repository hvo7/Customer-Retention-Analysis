USE Online_Retail;

WITH Monthly_Revenue AS 
(
	SELECT
		a.CustomerID,
		b.RFM_Score,
		DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Month_Year,
		SUM(Revenue) AS Monthly_Revenue
	FROM dbo.Online_Retail_Analysis a
	JOIN dbo.RFM_Analysis b
		ON a.CustomerID = b.CustomerID
	WHERE a.CustomerID IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
	GROUP BY a.CustomerID,
		b.RFM_Score,
		YEAR(InvoiceDate),
		MONTH(InvoiceDate)
),

Months AS 
(
	SELECT 
		Distinct(Month_Year) AS Month_Year
	FROM Monthly_Revenue
)

SELECT
		CustomerID,
		RFM_Score,
		b.Month_Year,
		COALESCE(Monthly_Revenue,0) AS Monthly_Revenue
FROM Monthly_Revenue a
CROSS JOIN Months b
ORDER BY CustomerID, b.Month_Year



----Diffs AS (
--	SELECT
--		CustomerID,
--		RFM_Score,
--		b.Month_Year,
--		a.Half,
--		COALESCE(Monthly_Revenue,0),
--		COALESCE(Monthly_Revenue - LAG(Monthly_Revenue, 1) OVER (PARTITION BY CustomerID ORDER BY Month_Year ASC),0) AS Revenue_Diff
--	FROM Monthly_Revenue a
--	FULL JOIN Months b
--		ON a.Month_Year = b.Month_Year
--),

--Avg_Diffs AS 
--(
--	SELECT
--		CustomerID,
--		RFM_Score,
--		Half,
--		AVG(Revenue_Diff) AS Avg_Rev_Diff
--	FROM Diffs
--	GROUP BY CustomerID, RFM_Score, Half
--)

--SELECT
--	RFM_Score,
--	COUNT(RFM_Score) AS Number_Customers,
--	COALESCE(ROUND(Avg(Avg_Rev_Diff),2),0) AS Avg_Change_Rev
--FROM Avg_Diffs
--GROUP BY RFM_Score
--ORDER BY RFM_Score DESC