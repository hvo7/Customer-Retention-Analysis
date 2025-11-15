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
		MAX(InvoiceDate) AS Recent_Purchase,
		COUNT(DISTINCT(
						DATEFROMPARTS(YEAR(InvoiceDate), Month(InvoiceDate), DAY(InvoiceDate))
					   )
			  ) AS Num_Orders,
		ROUND(SUM(Revenue),2) AS Total_Revenue
	FROM Orders
	GROUP BY CustomerID
),

Quartile_Vals AS
(
	SELECT
		MIN(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Recent_Purchase) OVER ()) AS R_q1,
		MIN(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Recent_Purchase) OVER ()) AS R_q2,
		MIN(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Recent_Purchase) OVER ()) AS R_q3,

		MIN(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Num_Orders) OVER ()) AS F_q1,
		MIN(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Num_Orders) OVER ()) AS F_q2,
		MIN(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Num_Orders) OVER ()) AS F_q3,

		MIN(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Total_Revenue) OVER ()) AS M_q1,
		MIN(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Total_Revenue) OVER ()) AS M_q2,
		MIN(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Total_Revenue) OVER ()) AS M_q3
	FROM RFM
)

--Scores AS 
--(
--SELECT 
--	CASE
--		WHEN Recent_Purchase < R_q1 THEN 4
--		WHEN Recent_Purchase < R_q2 THEN 3
--		WHEN Recent_Purchase < R_q3 THEN 2
--	ELSE 1
--	END AS R

	
SELECT
	*
FROM Quartile_Vals
