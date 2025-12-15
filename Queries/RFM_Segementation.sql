-- Objective: Segment Customers based on RFM Analysis and determine how each segment contributes to revenue and number of orders
-- Conclusion: Lost and At-risk High Value represent almost half of customers and 20% of revenue -> Best ROI opportunity

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
	Days_From_Last,
	Num_orders,
	Ln_Num_Orders,
	Total_Revenue,
	R,
	F,
	M,
	RFM,
	CASE 
		WHEN RFM = '444' 
			THEN 'Champions' -- 444
		WHEN (R IN (3,4) AND F = 4 ) 
			THEN 'Loyalist' -- Shop Frequently								
		WHEN (R = 4 AND F = 3 AND M IN (1,2))
				OR (R = 3 AND F = 3) -- Approaching Consistent Purchases
				OR (R = 3 AND F = 2 AND M IN (3,4)) -- High Recency, Med Freq, High Spend = Bought recently, and repeat big purchase
			THEN 'Potential Loyalist'
		WHEN (R = 4 AND F IN (2,3) AND R IN (3,4)) 
			OR (RFM = '314')
			THEN 'Promising' -- Most Recent Big Purchase, Freq too low to be considered loyal
		WHEN R = 4 AND F = 1 
			THEN 'New Customers' -- Most Recent and Lowest Freq, can't fully determine behavior yet
		WHEN R = 3 AND F IN (1,2) AND M IN (1,2,3) 
			THEN 'Need Attention'-- High recent, low-med freq, spending is low-okay
		WHEN (R IN (1,2) AND F = 4)
				OR (R IN (1,2) AND F IN (1,2,3) AND M IN (3,4) AND RFM NOT IN ('113','114'))
			THEN 'At-Risk High Value' -- Used to be valuable either in F or M but are inactive
		WHEN (R = 1 AND F = 1) 
			OR (R IN (1,2) AND F IN (1,2,3) AND M IN (1,2,3))
			THEN 'Lost' 
	ELSE 'Other'
	END AS Segment
	FROM Scores
)

-- 4 = Highest
-- 3 = High
-- 2 = Med
-- 1  = LoW

SELECT *
FROM Segmentation
ORDER BY CustomerID ASC



-- Look at Segment Metrics grouped by each segment

--SELECT
--	Segment,
--	COUNT(*) AS Num_Cust,
--	ROUND(CAST(COUNT(*) AS FLOAT) / CAST(4339 AS FLOAT),4) AS Num_Cust_Percentage,
--	SUM(Num_Orders) AS Total_Orders,
--	ROUND(SUM(Total_Revenue),4) AS Total_Revenue,
--	ROUND(CAST(SUM(Total_Revenue) AS FLOAT) / CAST(6501398.3 AS FLOAT),4) AS Percent_Rev
--FROM Segmentation
--GROUP BY Segment
--ORDER BY ROUND(SUM(Total_Revenue),2) DESC

--4339 Total Customers


