USE Online_Retail;

DECLARE @asof DATE = (
	SELECT
		MAX(CAST (InvoiceDate AS DATE)) 
	FROM dbo.Online_Retail_Analysis
);

;WITH Orders AS 
(
	SELECT
		CustomerID,
		InvoiceNo,
		MIN(InvoiceDate) AS Purchase_Date
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND Quantity > 0
	GROUP BY 
		CustomerID,
		InvoiceNo
),

Gaps AS
(
	SELECT
		CustomerID,
		Purchase_Date,
	LAG(Purchase_Date, 1) OVER (PARTITION BY 
										CustomerID 
										ORDER BY Purchase_Date ASC
									) AS Prev_Purchase_Date
	FROM Orders
),

Repeat_Gaps AS
(
	SELECT
		CustomerID,
		Purchase_Date,
		DATEDIFF(Day, 
				 Prev_Purchase_Date,
				 Purchase_Date
				) AS Days_Between
	FROM Gaps
	WHERE Prev_Purchase_Date IS NOT NULL		--Remove First Purchase dates
),

Threshold AS 
(
-- Assuming that 80% of repeat purchases happen within T days. In this case T = 63
	SELECT
		 TOP 1 PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY Days_Between ASC) OVER () AS T
	FROM Repeat_Gaps
),

-- Now Get info per customer
Customer AS 
(
	SELECT
		CustomerID,
		COUNT(DISTINCT(InvoiceDate)) AS Num_Orders,
		MIN(InvoiceDate) AS First_Purchase,
		MAX(InvoiceDate) AS Last_Purchase,
		DATEDIFF(DAY, MIN(InvoiceDate), @asof) AS Days_From_Last
	FROM dbo.Online_Retail_Analysis
	GROUP BY CustomerID
)

SELECT
	CustomerID,
	Num_Orders,
	First_Purchase,
	Last_Purchase,
	Days_From_Last,
	Thres.T AS Churn_Critical_Window_Days,
	CASE
-- First time customer have initial grace period of T = 63 days, else they're at risk
		WHEN Num_Orders <= 1 AND Days_From_Last < Thres.T THEN 'Grace Period'
		WHEN Num_Orders <= 1 AND Days_From_Last >= Thres.T THEN 'At Risk - First_Customer'
-- Repeat Customers are at risk if they are beyond grace period 
		WHEN Num_Orders > 1 AND Days_From_Last > Thres.T THEN 'At Risk - Repeat Customer'
		WHEN Num_Orders > 1 AND Days_From_Last >= 0.75*Thres.T THEN 'Approaching At-Risk - Repeat Customer'
	ELSE 'Healthy'
	END AS Churn_Risk_Group
FROM Customer
CROSS JOIN Threshold Thres
WHERE CustomerID IS NOT NULL
ORDER BY CustomerID ASC, Days_From_Last DESC