-- SELECT *
-- FROM dbo.Online_Retail_Cleaned
-- WHERE TRY_CONVERT(DATETIME, [InvoiceDate]) IS NULL
--   AND [InvoiceDate] IS NOT NULL
--   AND LTRIM(RTRIM([InvoiceDate])) <> '';

/* we see a big problem in the way the data transferred into mssql. it all shifted to the right by one value. 
                InvoiceNo   StockCode            Description                    Quantity         InvoiceDate     UnitPrice CustomerID            Country
     Bad Row Ex: 536381	        82567	    "AIRLINE LOUNGE	METAL SIGN"	            2	               12/1/2010        9:41	2.1	            15311,United Kingdom
    Fixed the error by replacing commas in the Description column with ";" -> retransferred the db*/

USE Online_Retail;

GO

-- Validate data by using Distinct on each column

SELECT *
FROM dbo.Online_Retail

/* First, I will address:

Which Customers do we target that are most likely to be retained?

I will use Recency, Frequency, and Market Value analysis. */

-- SELECT InvoiceDate, CustomerID
-- FROM dbo.Online_Retail
-- CAST(InvoiceDate AS Date) AS InvoiceDate