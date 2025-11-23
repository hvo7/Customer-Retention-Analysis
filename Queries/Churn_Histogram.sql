USE Online_Retail;

-- Calculate Churn Window: 86 Days
-- We use the 80% rule where "80% of customer purchase gaps are X amount of days or less (X is our churn window). Beyond X, customers are very likely to churn"
-- X = 86 Days

--WITH Purchases AS 
--(
--	SELECT
--		CustomerID,
--		InvoiceNo,
--		MIN(InvoiceDate) AS InvoiceDate
--	FROM dbo.Online_Retail_Analysis
--	WHERE CustomerID IS NOT NULL
--		AND InvoiceNo NOT LIKE '%C%'
--	GROUP BY CustomerID, InvoiceNo
--),

--Next_Date AS
--(
--	SELECT
--		CustomerID,
--		InvoiceNo,
--		InvoiceDate,
--		LEAD(InvoiceDate) OVER (PARTITION BY CustomerID ORDER BY InvoiceDate ASC) AS Next_Date
--	FROM Purchases
--),

--Gaps AS
--(
--	SELECT
--		CustomerID,
--		InvoiceNo,
--		InvoiceDate,
--		CASE
--			WHEN Next_Date IS NULL THEN DATEDIFF(DAY, InvoiceDate, (SELECT MAX(InvoiceDate) FROM dbo.Online_Retail_Analysis)) 
--			ELSE DATEDIFF(DAY, InvoiceDate, Next_Date) 
--			END AS Days_From_Last
--	FROM Next_Date
--)

--SELECT
--	PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY Days_From_Last ASC) OVER () AS Churn_Window
--FROM Gaps
--WHERE Days_From_Last > 0

WITH Purchases AS 
(
	SELECT
		CustomerID,
		InvoiceNo,
		MIN(InvoiceDate) AS InvoiceDate
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
	GROUP BY CustomerID, InvoiceNo
),

First_Last_Purchases AS
(
	SELECT
		CustomerID,
		MAX(InvoiceDate) AS Last_Purchase,
		MIN(InvoiceDate) AS First_Purchase
	FROM Purchases
	GROUP BY CustomerID
),

Lifetime AS
(
	SELECT
		CustomerID,
		DATEDIFF(DAY, First_Purchase, Last_Purchase) AS Lifetime
	FROM First_Last_Purchases
),

Final_Gap AS
(
	SELECT
		a.CustomerID,
		DATEDIFF(DAY, Last_Purchase, (SELECT MAX(InvoiceDate) FROM dbo.Online_Retail_Analysis)) AS Final_Gap
	FROM First_Last_Purchases a
)

SELECT
	a.CustomerID,
	Lifetime,
	Final_Gap
FROM Final_Gap a
	LEFT JOIN Lifetime b
		ON a.CustomerID = b.CustomerID
WHERE Final_Gap > 86