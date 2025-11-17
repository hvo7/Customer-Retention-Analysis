USE Online_Retail;

WITH Orders AS
(
	SELECT
		CustomerID,
		InvoiceDate,
		Revenue
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL	
		AND InvoiceNo NOT LIKE '%C%'
	GROUP BY CustomerID, InvoiceDate, Revenue
),

RFM AS
(
	SELECT
		CustomerID,
		DATEDIFF(DAY, MAX(InvoiceDate), DATEFROMPARTS(2011, 12, 10)) AS Days_From_Last,
		COUNT(DISTINCT(
						DATEFROMPARTS(YEAR(InvoiceDate), Month(InvoiceDate), DAY(InvoiceDate))
					   )
			  ) AS Num_orders,
		LOG(COUNT(DISTINCT(
						DATEFROMPARTS(YEAR(InvoiceDate), Month(InvoiceDate), DAY(InvoiceDate))
					   )
			  ) + 1) AS Ln_Num_Orders,
		ROUND(SUM(Revenue),2) AS Total_Revenue
	FROM Orders
	GROUP BY CustomerID
),

Quintile_Vals AS
(
	SELECT
		PERCENTILE_CONT(0.20) WITHIN GROUP (ORDER BY Days_From_Last DESC) OVER () AS R_q1,
		PERCENTILE_CONT(0.40) WITHIN GROUP (ORDER BY Days_From_Last DESC) OVER () AS R_q2,
		PERCENTILE_CONT(0.60) WITHIN GROUP (ORDER BY Days_From_Last DESC) OVER () AS R_q3,
		PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY Days_From_Last DESC) OVER () AS R_q4,

		PERCENTILE_CONT(0.20) WITHIN GROUP (ORDER BY Ln_Num_Orders ASC) OVER () AS F_q1,
		PERCENTILE_CONT(0.40) WITHIN GROUP (ORDER BY Ln_Num_Orders ASC) OVER () AS F_q2,
		PERCENTILE_CONT(0.60) WITHIN GROUP (ORDER BY Ln_Num_Orders ASC) OVER () AS F_q3,
		PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY Ln_Num_Orders ASC) OVER () AS F_q4,

		PERCENTILE_CONT(0.20) WITHIN GROUP (ORDER BY Total_Revenue ASC) OVER () AS M_q1,
		PERCENTILE_CONT(0.40) WITHIN GROUP (ORDER BY Total_Revenue ASC) OVER () AS M_q2,
		PERCENTILE_CONT(0.60) WITHIN GROUP (ORDER BY Total_Revenue ASC) OVER () AS M_q3,
		PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY Total_Revenue ASC) OVER () AS M_q4

	FROM RFM 
),

Calc_Scores AS 
(
SELECT 
	CustomerID,
	Days_From_Last,
	Num_orders,
	Ln_Num_Orders,
	Total_Revenue,

	CASE
		WHEN Days_From_Last > R_q1 THEN 1
		WHEN Days_From_Last > R_q2 THEN 2
		WHEN Days_From_Last > R_q3 THEN 3
		WHEN Days_From_Last > R_q4 THEN 4
	ELSE 5
	END AS R,

	CASE
		WHEN Ln_Num_Orders <= F_q1 THEN 1
		WHEN Ln_Num_Orders <= F_q2 THEN 2
		WHEN Ln_Num_Orders <= F_q3 THEN 3
		WHEN Ln_Num_Orders <= F_q4 THEN 4
	ELSE 5
	END AS F,


	CASE
		WHEN Total_Revenue < M_q1 THEN 1
		WHEN Total_Revenue < M_q2 THEN 2
		WHEN Total_Revenue < M_q3 THEN 3
		WHEN Total_Revenue < M_q4 THEN 4
	ELSE 5
	END AS M
FROM RFM a
CROSS JOIN Quintile_Vals b
),

Scores AS
(
SELECT
	CustomerID,
	Days_From_Last,
	Num_orders,
	Ln_Num_Orders,
	Total_Revenue,
	R,
	F,
	M,
	CONCAT(CAST(R AS varchar(1)), CAST(F AS varchar(1)), CAST(M AS varchar(1))) AS RFM,
	R + F + M AS RFM_Sum
From Calc_Scores
GROUP BY CustomerID,
	Days_From_Last,
	Num_orders,
	Ln_Num_Orders,
	Total_Revenue,
	R,
	F,
	M,
	CONCAT(CAST(R AS varchar(1)), CAST(F AS varchar(1)), CAST(M AS varchar(1)))
),

Segmentation AS
(
	SELECT
	CustomerID,
	R,
	F,
	M,
	RFM,
	RFM_Sum,
	CASE 
		WHEN RFM = '555' THEN 'Champions'
		WHEN F = 1 AND M = 5 THEN 'Whales' -- High Spender, low frequency
	END AS Segment

	FROM Scores
)

SELECT
	*
FROM Scores
ORDER BY CustomerID