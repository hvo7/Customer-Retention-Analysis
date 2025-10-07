USE Online_Retail;

WITH RFM AS
(
	SELECT	
		CustomerID,
		Recency,
		Frequency,
		RFM_Score,
		CASE 
			WHEN (CAST(Recency AS INT) + CAST(Frequency AS INT)) IN (2,3,4) THEN 'High_Risk'
			WHEN (CAST(Recency AS INT) + CAST(Frequency AS INT)) IN (9,10) THEN 'Low_Risk'
			ELSE 'Medium_Risk'
		END AS Risk_Group
	FROM dbo.RFM_Analysis
)

SELECT
	a.CustomerID,
	RFM_Score,
	Risk_Group,
	Country
FROM dbo.Online_Retail_Analysis a
INNER JOIN RFM b
ON a.CustomerID = b.CustomerID
