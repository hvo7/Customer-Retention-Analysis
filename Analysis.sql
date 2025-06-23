-- SELECT
--   [CustomerID],
--   CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [InvoiceDate]), 0)) AS ActivityMonth,
--   MIN(CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [InvoiceDate]), 0)))
--       OVER (PARTITION BY [CustomerID]) AS CohortMonth
-- FROM [dbo].[Online_Retail_Cleaned]
-- WHERE [CustomerID] IS NOT NULL;


-- SELECT 
-- DISTINCT(InvoiceDate)
-- FROM dbo.Online_Retail_Cleaned
-- ORDER BY InvoiceDate

-- SELECT *
-- FROM dbo.Online_Retail_Cleaned
-- WHERE TRY_CONVERT(DATETIME, [InvoiceDate]) IS NULL
--   AND [InvoiceDate] IS NOT NULL
--   AND LTRIM(RTRIM([InvoiceDate])) <> '';
-- we see a big problem in the way the data transferred into mssql. it all shifted to the right by one value. 
-- Ex: 536381	82567	"AIRLINE LOUNGE	METAL SIGN"	2	12/1/2010 9:41	2.1	15311,United Kingdom