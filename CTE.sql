WITH melhor_vendedor AS 
(
    SELECT TOP (10)
            SOH.SalesPersonID                       AS  'ID_VENDEDOR'
        ,   CONCAT(PP.FirstName,' ', PP.LastName)   AS  'NOME_VENDEDOR'
        ,   SUM(SOD.LineTotal)                      AS  'TOTAL_VENDAS' 

    FROM AdventureWorks2019.Sales.SalesOrderHeader SOH (NOLOCK)

    INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail SOD (NOLOCK) ON
        SOH.SalesOrderID = SOD.SalesOrderID
    
    INNER JOIN AdventureWorks2019.Person.Person PP (NOLOCK) ON
        SOH.SalesPersonID = PP.BusinessEntityID

    GROUP BY SOH.SalesPersonID, PP.FirstName, PP.LastName

    ORDER BY TOTAL_VENDAS DESC
),

salarios  AS
(
    SELECT 
                BusinessEntityID    AS 'ID'
          ,     Rate                AS 'SALARIO' 
    FROM AdventureWorks2019.HumanResources.EmployeePayHistory HRE
    INNER JOIN melhor_vendedor MV (NOLOCK) ON
        ID_VENDEDOR = HRE.BusinessEntityID
)

SELECT 
            MV.ID_VENDEDOR
        ,   MV.NOME_VENDEDOR
        ,   FORMAT(MV.TOTAL_VENDAS, 'c','pt-br')    AS  'TOTAL_VENDAS' 
        ,   FORMAT(SA.SALARIO, 'c', 'pt-br')        AS  'SALARIO/HORA'
        ,   CASE
                WHEN    TOTAL_VENDAS    BETWEEN 3000000 AND 5000000     THEN    '10%'
                WHEN    TOTAL_VENDAS    BETWEEN 5000001 AND 7000000     THEN    '12%' 
                WHEN    TOTAL_VENDAS    BETWEEN 7000001 AND 9000000     THEN    '15%'
                WHEN    TOTAL_VENDAS    BETWEEN 9000001 AND 10000000    THEN    '17%'
                WHEN    TOTAL_VENDAS    > 10000001                      THEN    '20%'
            END AS 'Bonus'
FROM melhor_vendedor MV (NOLOCK)
INNER JOIN salarios SA (NOLOCK) ON
    SA.ID = MV.ID_VENDEDOR


