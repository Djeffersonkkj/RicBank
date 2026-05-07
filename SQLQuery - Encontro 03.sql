-- Encontro 03

-- Tabela temporaria
-- CREATE TABLE #NomeTabela
-- Quando acaba o contexto a tabela desaparece (geralmente a mais usada).

-- CREATE TABLE ##NomeTabela
-- Cria uma tabela global, ou seja, outros computadores podem ver.

-- quando passa ela como parametro usa @ no lugar do #

DROP TABLE IF EXISTS #Conta;

CREATE TABLE #Conta (
    Id              INT,
    IdCliente       INT,    
    IdAgencia       INT,             
    Numero          VARCHAR(20),     
    Tipo            CHAR(1),         
    Saldo           DECIMAL(15,2),   
    Situacao        VARCHAR(20),     
    DataAbertura    DATETIME,
    SaldoMedioAgencia DECIMAL(18, 2) NULL
); 
-- colocar not null e coisas desse tipo apenas se estiver criando uma tabela nova
GO

SELECT Id, IdCliente, IdAgencia, Numero, Tipo, Saldo, Situacao, DataAbertura
    FROM dbo.Conta

INSERT INTO #Conta (Id, IdCliente, IdAgencia, Numero, Tipo, Saldo, Situacao, DataAbertura)
    SELECT Id, IdCliente, IdAgencia, Numero, Tipo, Saldo, Situacao, DataAbertura
        FROM dbo.Conta WITH(NOLOCK);

SELECT * 
    FROM #Conta;

DELETE 
    FROM #Conta;

INSERT INTO #Conta (Id, IdCliente, IdAgencia, Numero, Tipo, Saldo, Situacao, DataAbertura, SaldoMedioAgencia)
    SELECT  Id, 
            IdCliente, 
            IdAgencia, 
            Numero, 
            Tipo, 
            Saldo, 
            Situacao, 
            DataAbertura, 
            (SELECT AVG(Saldo) AS Media
                FROM dbo.Conta as co2 -- WITH(NOLOCK) perguntar se precisa.
                WHERE co2.IdAgencia = co1.IdAgencia
                GROUP BY co2.IdAgencia)
        FROM dbo.Conta as co1 WITH(NOLOCK);

SELECT * 
    FROM #Conta
    ORDER BY Saldo ASC;

DELETE
    FROM #Conta
    WHERE Id = (SELECT  TOP(1)
                        Id
                    FROM #Conta 
                    ORDER BY Saldo);

SELECT * 
    FROM #Conta
    ORDER BY Saldo ASC;

SELECT  co.Id,
        co.IdAgencia,
        co.Numero,
        co.Saldo,
        co.SaldoMedioAgencia
    FROM #Conta as co
    WHERE co.Saldo > co.SaldoMedioAgencia;

SELECT  co.Id,
        co.IdAgencia,
        co.Numero,
        co.Saldo,
        co.SaldoMedioAgencia,
        CASE
            WHEN Saldo % 2 != 0 THEN 'Impar'
            ELSE 'Par'
            END AS ImpaPar
    FROM #Conta as co

UPDATE #Conta
    SET Saldo = Saldo + 1000
    WHERE Id = (SELECT  TOP(1)
                        Id
                    FROM #Conta
                    ORDER BY Saldo);

SELECT * 
    FROM #Conta
    ORDER BY Saldo ASC;

DROP TABLE IF EXISTS #Conta;



    