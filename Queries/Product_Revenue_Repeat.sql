USE Online_Retail;

WITH Repeat_Customer AS
(
	SELECT 
		CustomerID,
		CASE
			WHEN COUNT(DISTINCT(InvoiceDate)) > 1 THEN 1
			ELSE 0 
		END AS Repeat_Customer_Flag
	FROM dbo.Online_Retail_Analysis
	WHERE InvoiceNo NOT LIKE '%C%'
	GROUP BY CustomerID
),

Non_Repeat_Customer_Products AS
(
	SELECT
		Description,
		ROUND(SUM(Revenue),2) AS Total_Revenue_Non_Repeat	
	FROM dbo.Online_Retail_Analysis a
	JOIN Repeat_Customer b
		ON a.CustomerID = b.CustomerID
	WHERE Repeat_Customer_Flag = 0
		AND InvoiceNo NOT LIKE '%C%'
		AND Description IS NOT NULL
	GROUP BY Description
),

Repeat_Customer_Products AS
(
	SELECT
		Description,
		ROUND(SUM(Revenue),2) AS Total_Revenue_Repeat	
	FROM dbo.Online_Retail_Analysis a
	JOIN Repeat_Customer b
		ON a.CustomerID = b.CustomerID
	WHERE Repeat_Customer_Flag = 1
		AND InvoiceNo NOT LIKE '%C%'
		AND Description IS NOT NULL
	GROUP BY Description
)

SELECT
	a.Description,
	Total_Revenue_Non_Repeat,
	Total_Revenue_Repeat
FROM Non_Repeat_Customer_Products a
JOIN Repeat_Customer_Products b
	ON a.Description = b.Description
ORDER BY Description
