USE Online_Retail;


DECLARE @CriticalWindow INT = 60;
DECLARE @Midpoint DATE = '2011-06-05 22:38:00.0000000';

WITH orders AS 
(
	SELECT
	DISTINCT
		CustomerID,
		InvoiceDate,
		ROUND(SUM(Revenue) OVER(PARTITION BY CustomerID),2) AS Total_Revenue
	FROM dbo.Online_Retail_Analysis
	WHERE InvoiceNo NOT LIKE '%C%'
		AND CustomerID IS NOT NULL
),

-- Calculate the midpoint datetime
-- Midpoint Datetime: 2011-06-05 22:38:00.0000000

--WIth Bounds AS (
--	SELECT 
--		MIN(InvoiceDate) AS MinD, 
--		MAX(InvoiceDate) AS MaxD
--	FROM dbo.Online_Retail_Analysis
--)

--SELECT
--	DATEADD(second, DATEDIFF(second, MinD, MaxD)/2, MinD) AS Midpoint
--FROM Bounds

Customer_Count AS
(
	SELECT
		DISTINCT
			CustomerID,
	FROM orders
	WHERE InvoiceDate 


)

Prev_Orders AS (
	SELECT
		CustomerID,
		InvoiceDate,
		lAG(InvoiceDate) OVER (PARTITION BY CustomerID ORDER BY InvoiceDate ASC) AS Prev_Order,
		COALESCE(DATEDIFF(DAY, LAG(InvoiceDate) OVER (PARTITION BY CustomerID ORDER BY InvoiceDate ASC), InvoiceDate),0) AS Days_Since_Prev
	FROM orders
)

SELECT
	CustomerID,
	InvoiceDate,
	Prev_Order,
	Days_Since_Prev,
	CASE
		WHEN Days_Since_Prev > 49 THEN 1
		ELSE 0
	END AS Churned_Flag
FROM Prev_Orders
WHERE Prev_Order IS NOT NULL
ORDER BY CustomerID, InvoiceDate

-- Calculate the critical window
-- Critical Window = 49 days

--SELECT
--	DISTINCT
--		CAST(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY Days_Since_Prev) OVER () AS INT) AS Critical_Window
--FROM Prev_Orders

-- Calcuated 49 Days as the crtiical window before a customer churns using the idea of the 80/20 rule (Crtiical window is within the top 80 percentage)



