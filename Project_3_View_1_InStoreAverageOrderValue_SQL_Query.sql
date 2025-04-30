-------------------------InStore--------------------------
CREATE OR ALTER VIEW View_1_InStoreAverageOrderValue AS
SELECT
    S.StoreID,
    S.Location AS StoreLocation,
    CAST(SUM(IST.Amount) * 1.0 / COUNT(IST.TransactionID) AS DECIMAL(10,2)) AS AverageOrderValue
FROM
    InStoreTransactions IST
JOIN
    Stores S ON IST.StoreID = S.StoreID
GROUP BY
    S.StoreID, S.Location;


select * from View_1_InStoreAverageOrderValue;