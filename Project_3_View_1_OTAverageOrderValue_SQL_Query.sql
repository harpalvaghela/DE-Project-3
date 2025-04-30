-----OnlineTransactions only - AOV for Online Only

CREATE OR ALTER VIEW View_1_OTAverageOrderValue AS
SELECT
    P.ProductID,
    P.Name AS ProductName,
    P.Category,
    CAST(SUM(OT.Amount) * 1.0 / COUNT(OT.OrderID) AS DECIMAL(10,2)) AS AverageOrderValue
FROM
    OnlineTransactions OT
JOIN
    Products P ON OT.ProductID = P.ProductID
GROUP BY
    P.ProductID, P.Name, P.Category;


Select * from View_1_OTAverageOrderValue