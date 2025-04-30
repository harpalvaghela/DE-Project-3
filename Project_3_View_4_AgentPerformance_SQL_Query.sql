---4) Agent Interactions and Resolution Success Rate
CREATE OR ALTER VIEW View_4_AgentPerformance AS
SELECT
    A.AgentID,
    A.Name AS AgentName,
    COUNT(CSI.InteractionID) AS TotalInteractions,
    SUM(CASE WHEN CSI.ResolutionStatus = 'Resolved' THEN 1 ELSE 0 END) AS ResolvedInteractions,
    CAST(
        CASE 
            WHEN COUNT(CSI.InteractionID) = 0 THEN 0
            ELSE (SUM(CASE WHEN CSI.ResolutionStatus = 'Resolved' THEN 1 ELSE 0 END) * 1.0 / COUNT(CSI.InteractionID)) * 100
        END AS DECIMAL(10,2)
    ) AS ResolutionSuccessRate
FROM
    Agents A
LEFT JOIN
    CustomerServiceInteractions CSI ON A.AgentID = CSI.AgentID
GROUP BY
    A.AgentID, A.Name;

--------------------------------------------
Select * from View_4_AgentPerformance;