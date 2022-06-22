## Hoje iremos abordar sobre a common table expression ou CTE para os mais chegados.

#### **Podemos imaginar uma CTE como uma inline view ou uma tabela temporaria, ou se você já tem habito de programar alguma linguagem orientada a objetos uma CTE em alguns casos pode se parecer com uma classe.**
#### **Definidos a CTE com seus campos e depois podemos chama-la quantas vezes for necessário no código, melhorando assim o reuso e consequentemente diminuindo a quantidade de linhas no cósigo, isso ajuda a deixar o mesmo mais legivel e também melhora o desempenho se comparado a Subquerys**
#### **As CTEs tem um nivel de abstração parecida com uma View, porém a CTE diferente da View não será compilada no banco de dados, ficando disponivel apenas no nivel de exibição e poderá ser chamada apenas pela sessão em que ela está alocada, neste ponto se assemelha muito a uma tabela temporária**
* ## Em que caso usar uma CTE
> Se existe várias SUBSELECT referenciando a mesma tabela em seu código, com certezaadotar uma CTE é o caminho mais recomendado, além de ganhar performace, deixará o seu desenvolvimento mais legível e de facil manutenção
---
## Código Explicativo
* *Declarando uma CTE.*
>Existe duas formas de fazer isso, informando o nome dos campos logo após a declaração da CTE ou informando o nome dos campos no apelido (álias) de tabela, EXEMPLO:
~~~sql
WITH nome_da_cte (campo1,campo2) AS
(SELECT teste1,teste2 FROM tb)
~~~
>Onde o **campo1** pegara a informação do **teste1** e o **campo2** pegara a informação do **teste2**, OU:
~~~sql
WITH nome_da_cte AS
(SELECT teste1 AS 'campo1', teste2 AS 'campo2' FROM tb)
~~~
> * Para o nosso exemplo iremos seguir com o segundo exemplo
---
#### 1. **CTE Principal onde irei retornar a base da minha Query**
~~~sql
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
~~~
---
#### 2. **CTE Secundaria para retornar dados especificos para complementar o todo da Query**
~~~sql
salarios  AS
(
    SELECT 
                BusinessEntityID    AS 'ID'
          ,     Rate                AS 'SALARIO' 
    FROM AdventureWorks2019.HumanResources.EmployeePayHistory HRE
    INNER JOIN melhor_vendedor MV (NOLOCK) ON
        ID_VENDEDOR = HRE.BusinessEntityID
)
~~~
---
#### 3. **SELECT interna para exibir os dados consultados nas CTES**
~~~sql
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
~~~
---
# **RESULTADO**
<img src = img/img.png>

---

### **Fonte de Estudo**
* [WITH common_table_expression](https://docs.microsoft.com/pt-br/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver16)

* [SQL Server – Como criar consultas recursivas com a CTE (Common Table Expressions)](https://www.dirceuresende.com/blog/sql-server-como-criar-consultas-recursivas-com-a-cte-common-table-expressions/)

* [T-SQL - CTE - Common Table Expression (subconsultas) - SQL Server](https://www.youtube.com/watch?v=-o0ClA1JJlA&t=1s)
