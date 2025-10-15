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
)

SELECT
	Description, 
	ROUND(SUM(
			  CASE WHEN b.Repeat_Customer_Flag = 0 THEN a.Revenue ELSE 0 END
			 ),2) AS Total_Revenue_Non_Repeat,
	ROUND(SUM(
			  CASE WHEN b.Repeat_Customer_Flag = 1 THEN a.Revenue ELSE 0 END
			 ),2) AS Total_Revenue_Non_Repeat
FROM dbo.Online_Retail_Analysis a
LEFT JOIN Repeat_Customer b
	ON a.CustomerID = b.CustomerID
WHERE InvoiceNo NOT LIKE '%C%'
	AND Description IS NOT NULL
GROUP BY Description
ORDER BY Description
