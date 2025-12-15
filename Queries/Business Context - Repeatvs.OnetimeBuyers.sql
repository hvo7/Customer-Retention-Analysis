-- Objective: Examine the differences in revenue and number of customers for one time buyers vs. repeat purchasers
--
-- Conclusion: 
--			Repeat Purchasers represent the majority of customers
--			Repeat Purchasers contribute much more to total revenue than one time buyers

USE Online_Retail;

WITH Orders AS 
(
	SELECT
		DISTINCT CustomerID,
		InvoiceNo,
		MIN(InvoiceDate) AS InvoiceDate,
		SUM(Revenue) AS Revenue
	FROM dbo.Online_Retail_Analysis
	WHERE CustomerID IS NOT NULL
		AND InvoiceNo NOT LIKE '%C%'
	GROUP BY 
		CustomerID,
		InvoiceNo
),

Num_Orders AS 
(
	SELECT
		CustomerID,
		COUNT(InvoiceNo) AS Num_Orders,
		SUM(Revenue) AS Total_Revenue
	FROM Orders
	GROUP BY CustomerID
),

Repeat_Flag AS
(
	SELECT
		CustomerID,
		CASE
			WHEN Num_Orders > 1 THEN 1
		ELSE 0
		END AS Repeat_Flag,
		Total_Revenue
	FROM Num_Orders
)

SELECT 
	Repeat_Flag,
	SUM(CAST(Total_Revenue AS Decimal(18,2))) AS Total_Revenue,
	COUNT(*) AS Num_Customers
FROM Repeat_Flag
GROUP BY Repeat_Flag
ORDER BY Total_Revenue DESC

--SELECT
--	COUNT(DISTINCT CustomerID) AS Count,
--	CAST(SUM(Revenue) AS Decimal(18,2)) AS Total_Revenue
--FROM dbo.Online_Retail_Analysis
--WHERE CustomerID IS NOT NULL
--	AND InvoiceNo NOT LIKE '%C%'