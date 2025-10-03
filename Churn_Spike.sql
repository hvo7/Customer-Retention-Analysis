USE Online_Retail;

DECLARE @asof DATE = (
	SELECT
		MAX(CAST (InvoiceDate AS DATE)) 
	FROM dbo.Online_Retail_Analysis
)


WITH Orders AS 
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

T AS 
(
-- Assuming that 80% of repeat purchases happen within T days. In this case T = 63
	SELECT
		 TOP 1 PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY Days_Between ASC) OVER () AS T
	FROM Repeat_Gaps
)
