USE Online_Retail;

-- Divide our dataset into two halfs based on dates. Calculate Retention for both halves.

DECLARE @Mid_Date datetime2 = '2011-06-05 08:26:00.0000000';
-- Find midpoint of date
-- Midpoint date = 2011-06-05 08:26:00.0000000
--WITH Max_Min AS
--(
--	SELECT	
--		Max(InvoiceDate) AS Max_Date,
--		MIN(InvoiceDate) AS Min_Date
--	FROM dbo.Online_Retail_Analysis
--	WHERE InvoiceNo NOT LIKE '%C%'
--)

--SELECT
--	DATEADD(DAY, DATEDIFF(DAY, Min_Date, Max_Date) / 2, Min_Date) AS Mid_Date
--FROM Max_Min


WITH Orders AS 
(
	SELECT 
		CustomerID,
		TRY_CONVERT(datetime2, InvoiceDate) AS InvoiceDate
	FROM dbo.Online_Retail_Analysis
	WHERE InvoiceNo NOT LIKE '%C%'
),

First_Purchases AS 
(
	SELECT 
		CustomerID,
		MIN(InvoiceDate) AS First_Purchase
	FROM dbo.Online_Retail_Analysis
),

Half AS
(
	SELECT
		CustomerID,
		DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Month_Year,
		CASE WHEN InvoiceDate <= @Mid_Date
		THEN 1
		ELSE 2
		END AS Half
	FROM Orders
),

Bounds AS 
(
	SELECT
		MIN(CASE WHEN Half = 1 THEN Month_Year END) AS H1_Min_Date,
		MAX(CASE WHEN Half = 1 THEN Month_Year END) AS H1_Max_Date,
		MIN(CASE WHEN Half = 2 THEN Month_Year END) AS H2_Min_Date,
		MAX(CASE WHEN Half = 2 THEN Month_Year END) AS H2_Max_Date
	FROM Half
),

Num_Cust AS
(
	SELECT
		COUNT(DISTINCT
				(CASE 
				   WHEN Month_Year = H1_Min_Date AND Half = 1 THEN CustomerID ELSE NULL END
				)
			) AS H1_Start_Cust,

		COUNT(DISTINCT
				(CASE 
				   WHEN Month_Year = H1_Max_Date AND Half = 1 THEN CustomerID ELSE NULL END
				)
			) AS H1_End_Cust,

		COUNT(DISTINCT
				(CASE 
					WHEN Month_Year NOT IN (H1_Min_Date, H1_Max_Date) AND Half = 1 THEN CustomerID ELSE NULL END
				)
			) AS H1_New_Cust,

		COUNT(DISTINCT
				(CASE 
				   WHEN Month_Year = H2_Min_Date AND Half = 2 THEN CustomerID ELSE NULL END
				)
			) AS H2_Start_Cust,

		COUNT(DISTINCT
			(CASE 
				WHEN Month_Year = H2_Max_Date AND Half = 2 THEN CustomerID ELSE NULL END
			)
		) AS H2_End_Cust,

		COUNT(DISTINCT
				(CASE 
					WHEN Month_Year NOT IN (H2_Min_Date, H2_Max_Date) AND Half = 2 THEN CustomerID ELSE NULL END
				)
			) AS H2_New_Cust
	FROM 
		Half a
	CROSS JOIN Bounds b
),

Retention_Rates AS
(
	SELECT
		H1_End_Cust - H1_New


)
--SELECT
--	a.Half,
--	Start_Cust,
--	End_Cust
--FROM Start_Cust a
--CROSS JOIN End_Cust b