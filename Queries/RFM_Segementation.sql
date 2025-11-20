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
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Days_From_Last DESC) OVER () AS R_q1,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Days_From_Last DESC) OVER () AS R_q2,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Days_From_Last DESC) OVER () AS R_q3,

		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Ln_Num_Orders ASC) OVER () AS F_q1,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Ln_Num_Orders ASC) OVER () AS F_q2,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Ln_Num_Orders ASC) OVER () AS F_q3,

		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Total_Revenue ASC) OVER () AS M_q1,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Total_Revenue ASC) OVER () AS M_q2,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Total_Revenue ASC) OVER () AS M_q3

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
	ELSE 4
	END AS R,

	CASE
		WHEN Ln_Num_Orders <= F_q1 THEN 1
		WHEN Ln_Num_Orders <= F_q2 THEN 2
		WHEN Ln_Num_Orders <= F_q3 THEN 3
	ELSE 4
	END AS F,


	CASE
		WHEN Total_Revenue < M_q1 THEN 1
		WHEN Total_Revenue < M_q2 THEN 2
		WHEN Total_Revenue < M_q3 THEN 3
	ELSE 4
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
	CONCAT(CAST(R AS varchar(1)), CAST(F AS varchar(1)), CAST(M AS varchar(1))) AS RFM
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
	CASE 
		WHEN RFM = '444' THEN 'Champions' -- 444
		WHEN (R = 4 AND F = 4 ) 
			OR (R = 3 AND F = 4 AND M IN (2,3,4) )								
			OR	(R = 4 AND F = 3 AND M IN (2,3,4) )	THEN 'Loyalist'		
		WHEN (R = 3 AND F = 2  THEN 'Potential Loyalist'
		WHEN RFM IN ('424', '414', '413', '423') THEN 'Promising'
		WHEN R IN (3,4) AND F = 1 THEN 'New Customers'
		WHEN RFM IN ('322', '323', '332', '333') THEN 'Need Attention' 
		WHEN RFM IN ('244', '243', '234', '224', '214', '144', '143', '134', '233') THEN 'At-Risk High Value'
		WHEN RFM IN ('211', '212', '221', '222', '111','112', '113', '114', '121', '122') THEN 'Lost' 
	ELSE 'Other'
	END AS Segment
	FROM Scores
)



-- 4 = Highest
-- 3 = High
-- 2 = Med
-- 1  = Low


SELECT
	DISTINCT(RFM)
FROM Segmentation
WHERE Segment = 'Other'


--4339 Total Customers


