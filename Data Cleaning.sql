USE Online_Retail;
/*
UPDATE dbo.Online_Retail_Cleaned
SET Description = RTRIM
	(
	LTRIM
		(
			Replace
				(Description, '  ', ' ')
		)
	)
FROM dbo.Online_Retail_Cleaned
WHERE Description IS NOT NULL AND Description LIKE '%  %' 

*/

SELECT *
FROM dbo.Online_Retail_Cleaned



