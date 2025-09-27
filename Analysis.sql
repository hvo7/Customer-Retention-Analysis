USE Online_Retail;


WITH First_Orders AS (
    SELECT
        CustomerID,
        Description,
        MIN(InvoiceDate) AS First_Purchase
    FROM dbo.Online_Retail_Analysis
    WHERE Description IS NOT NULL
    GROUP BY CustomerID, Description
)
SELECT
    a.InvoiceNo,
    a.Description,
    a.CustomerID,
    a.InvoiceDate,
    CASE WHEN a.InvoiceDate > fo.First_Purchase THEN 1 ELSE 0 END AS Repeat_Flag
FROM dbo.Online_Retail_Analysis AS a
LEFT JOIN First_Orders AS fo
    ON fo.CustomerID = a.CustomerID
   AND fo.Description = a.Description
WHERE a.Description IS NOT NULL AND a.CustomerID IS NOT NULL
