-- Objective: Get a overview of current number of orders, revenue, number of customers

USE Online_Retail;

WITH Purchases AS
(
	SELECT
		CustomerID,
		InvoiceNo,
		CAST(InvoiceDate AS DATE) AS InvoiceDate,
		ROUND(SUM(Revenue),2) AS Total_Revenue
	FROM dbo.Online_Retail_Analysis
	WHERE InvoiceNo NOT LIKE '%C%'
	GROUP BY 
		CustomerID, 
		InvoiceNo, 
		CAST(InvoiceDate AS DATE)
),

Customer_Level AS
(
	SELECT
		CustomerID,
		SUM(Total_Revenue) AS Customer_Total_Revenue,
		COUNT(DISTINCT InvoiceNo) AS Num_Orders
	FROM Purchases
	GROUP BY CustomerID
),

Order_Distribution AS
(
	SELECT
		Num_Orders,
		COUNT(*) AS Count
	FROM Customer_Level
	GROUP BY Num_Orders
),

Revenue_Rank AS
(
	SELECT
		CustomerID,
		Customer_Total_Revenue,
		NTILE(100) OVER (ORDER BY Customer_Total_Revenue DESC) AS Percentile
	FROM Customer_Level
),

Overall_Revenue AS
(
	SELECT
		SUM(Customer_Total_Revenue) AS Overall_Revenue
	FROM Customer_Level
),

Revenue_Concentration AS
(
	SELECT
		SUM(CASE WHEN Percentile <= 5 THEN Customer_Total_Revenue END) * 1.0 / Overall_Revenue AS Top5pct_Revenue,
		SUM(CASE WHEN Percentile <= 10 THEN Customer_Total_Revenue END) * 1.0 / Overall_Revenue AS Top10pct_Revenue,
		SUM(CASE WHEN Percentile <= 20 THEN Customer_Total_Revenue END) * 1.0 / Overall_Revenue AS Top20pct_Revenue
	FROM Revenue_Rank
	CROSS JOIN Overall_Revenue
)

--KPI AS
--(
--	SELECT
--		COUNT(DISTINCT CustomerID) AS Total_Customers,
--		COUNT(DISTINCT InvoiceNo) AS Total_Orders,
--		ROUND(SUM(Total_Revenue),2) AS Overall_Revenue,
--		ROUND(AVG(Total_Revenue),2) AS Avg_Order_Value,
--		ROUND((COUNT(DISTINCT InvoiceNo) * 1.0 ) / (COUNT(DISTINCT CustomerID)),3) AS Avg_Purchase_Freq -- How many orders the average customer orders for this given time period
--	FROM Purchases
--)

SELECT
	*
FROM Revenue_Concentration