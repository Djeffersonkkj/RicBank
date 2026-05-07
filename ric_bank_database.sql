CREATE DATABASE RicBank;
GO

USE RicBank;
GO

CREATE TABLE dbo.Agencia (
	Id      INT             IDENTITY(1, 1),
	Numero  CHAR(10)        NOT NULL,
	Nome    VARCHAR(100)    NOT NULL,
	Cidade  VARCHAR(80)     NOT NULL,
	UF      CHAR(2)         NOT NULL,

	CONSTRAINT PK_IdAgencia     PRIMARY KEY (Id),
	CONSTRAINT UQ_Numero_Agencia UNIQUE (Numero)
);
GO

CREATE TABLE dbo.Cliente (
    Id              INT IDENTITY(1,1),
    Nome            VARCHAR(120)    NOT NULL,
    CPF             CHAR(11)        NOT NULL,
    DataNascimento  DATE            NOT NULL,
    Telefone        VARCHAR(20),   
    Email           VARCHAR(120),    
    Cidade          VARCHAR(80)     NOT NULL,
    UF              CHAR(2)         NOT NULL,
    DataCadastro    DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_IdCliente     PRIMARY KEY (Id),
    CONSTRAINT UQ_CPF_Cliente   UNIQUE (CPF)
);
GO

CREATE TABLE dbo.Conta (
    Id              INT             IDENTITY(1,1),
    IdCliente       INT             NOT NULL,
    IdAgencia       INT             NOT NULL,
    Numero          VARCHAR(20)     NOT NULL,
    Tipo            CHAR(1)         NOT NULL,
    Saldo           DECIMAL(15,2)   NOT NULL DEFAULT 0,
    Situacao        VARCHAR(20)     NOT NULL DEFAULT 'ATIVA',
    DataAbertura    DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_IdConta           PRIMARY KEY (Id),
    CONSTRAINT FK_IdCliente_Conta   FOREIGN KEY (IdCliente) REFERENCES dbo.Cliente(Id),
    CONSTRAINT FK_IdAgencia_Conta   FOREIGN KEY (IdAgencia) REFERENCES dbo.Agencia(Id),
    CONSTRAINT UQ_Numero_Conta      UNIQUE      (Numero),
);
GO

CREATE TABLE dbo.Cartao (
    Id              INT             IDENTITY(1,1),
    IdCliente       INT             NOT NULL,
    IdConta         INT             NOT NULL,
    Numero          CHAR(16)        NOT NULL,
    Tipo            VARCHAR(20)     NOT NULL,
    Limite          DECIMAL(18,2)   NOT NULL,
    DataValidade    DATE            NOT NULL,
    Situacao        VARCHAR(20)     NOT NULL DEFAULT 'ATIVO',

    CONSTRAINT PK_IdCartao           PRIMARY KEY (Id),
    CONSTRAINT FK_IdCliente_Cartao   FOREIGN KEY (IdCliente) REFERENCES dbo.Cliente(Id),
    CONSTRAINT FK_IdConta_Cartao     FOREIGN KEY (IdConta)   REFERENCES dbo.Conta(Id),
    CONSTRAINT UQ_Numero_Cartao      UNIQUE (Numero)
);
GO

CREATE TABLE dbo.Transacao (
    Id              INT             IDENTITY(1,1),
    IdConta         INT             NOT NULL,
    Tipo            VARCHAR(30)     NOT NULL,
    Valor           DECIMAL(18,2)   NOT NULL,
    DataTransacao   DATETIME        NOT NULL DEFAULT GETDATE(),
    Descricao       VARCHAR(200)    NULL,

    CONSTRAINT PK_IdTransacao       PRIMARY KEY (Id),
    CONSTRAINT FK_IdConta_Transacao FOREIGN KEY (IdConta) REFERENCES dbo.Conta(Id)
);
GO

CREATE TABLE dbo.Emprestimo (
    Id                  INT             IDENTITY(1,1),
    IdCliente           INT             NOT NULL,
    ValorSolicitado     DECIMAL(18,2)   NOT NULL,
    TaxaJuros           DECIMAL(5,2)    NOT NULL,
    QuantidadeParcelas  INT             NOT NULL,
    DataSolicitacao     DATETIME        NOT NULL DEFAULT GETDATE(),
    Situacao            VARCHAR(20)     NOT NULL DEFAULT 'EM_ANALISE',

    CONSTRAINT PK_IdEmprestimo          PRIMARY KEY (Id),
    CONSTRAINT FK_IdCliente_Emprestimo  FOREIGN KEY (IdCliente) REFERENCES dbo.Cliente(Id)
);
GO

CREATE TABLE dbo.AuditoriaOperacao (
    Id              INT             IDENTITY(1,1),
    Entidade        VARCHAR(50)     NOT NULL,
    Operacao        VARCHAR(30)     NOT NULL,
    DataEvento      DATETIME        NOT NULL DEFAULT GETDATE(),
    UsuarioEvento   VARCHAR(100)    NOT NULL DEFAULT SUSER_SNAME(),
    Detalhes        VARCHAR(500)    NULL,

    CONSTRAINT PK_IdAuditoriaOperacao PRIMARY KEY (Id)
);
GO

CREATE TABLE dbo.TipoLancamento(
	ID      TINYINT,
	Nome    VARCHAR(50) NOT NULL

	CONSTRAINT PK_IdTipoLancamento PRIMARY KEY (Id)
);
GO

CREATE TABLE dbo.OrigemLancamento(
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL

	CONSTRAINT PK_IdTipoOrigem PRIMARY KEY (Id)
);
GO

CREATE TABLE dbo.Lancamento(
	Id		            INT				IDENTITY,
	IdConta			    INT				NOT NULL,
	IdTipoLancamento	TINYINT				NOT NULL,
	IdOrigemLancamento	TINYINT				NOT NULL,
	DebitoCredito		CHAR(1)			NOT NULL,
	Descricao			VARCHAR(255)	NOT NULL,
	Valor				DECIMAL (15,2)	NOT NULL,
	DataLancamento		DATETIME		NOT NULL

	CONSTRAINT PK_IdLancamento			        PRIMARY KEY (Id),
	CONSTRAINT FK_IdConta_Lancamento            FOREIGN KEY (IdConta)				REFERENCES dbo.Conta(Id),
	CONSTRAINT FK_IdTipoLancamento_Lancamento	FOREIGN KEY (IdTipoLancamento)		REFERENCES dbo.TipoLancamento(Id),
	CONSTRAINT FK_IdOrigemLancamento_Lancamento	FOREIGN KEY (IdOrigemLancamento)	REFERENCES dbo.OrigemLancamento(Id),
    CONSTRAINT CHK_Operacao                     CHECK       (DebitoCredito LIKE '[c,C]' OR DebitoCredito LIKE '[D,d]')
);
GO

CREATE INDEX idx_ContaId
	ON dbo.Lancamento	(
							IdConta,
							DataLancamento
						);
GO

CREATE INDEX idx_OrigemLancamento
	ON dbo.Lancamento (IdOrigemLancamento);
GO

CREATE INDEX idx_TipoLancamento
	ON dbo.Lancamento (IdTipoLancamento);
GO

CREATE OR ALTER FUNCTION dbo.fn_CalcularTarifa (@Saldo DECIMAL(18,2))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Tarifa DECIMAL(18,2);
    SET @Tarifa = CASE
        WHEN @Saldo >= 5000 THEN 0
        WHEN @Saldo >= 1000 THEN 12.50
        ELSE 25.00
    END;
    RETURN @Tarifa;
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_ExtratoResumido (@IdConta INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 10 Id, DataTransacao, Tipo, Valor, Descricao
    FROM dbo.Transacao
    WHERE IdConta = @IdConta
    ORDER BY DataTransacao DESC
);
GO

CREATE OR ALTER PROCEDURE dbo.usp_Depositar
    @IdConta INT,
    @Valor DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Conta
    SET Saldo = Saldo + @Valor
    WHERE Id = @IdConta;

    INSERT INTO dbo.Transacao (IdConta, Tipo, Valor, Descricao)
    VALUES (@IdConta, 'DEPOSITO', @Valor, 'Deposito realizado');
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Sacar
    @IdConta INT,
    @Valor DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Conta WHERE Id = @IdConta AND Saldo >= @Valor)
    BEGIN
        UPDATE dbo.Conta
        SET Saldo = Saldo - @Valor
        WHERE Id = @IdConta;

        INSERT INTO dbo.Transacao (IdConta, Tipo, Valor, Descricao)
        VALUES (@IdConta, 'SAQUE', @Valor, 'Saque realizado');
    END
    ELSE
    BEGIN
        RAISERROR('Saldo insuficiente.',16,1);
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Transferir
    @ContaOrigemId INT,
    @ContaDestinoId INT,
    @Valor DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF (SELECT Saldo FROM dbo.Conta WHERE Id = @ContaOrigemId) < @Valor
            RAISERROR('Saldo insuficiente para transferencia.',16,1);

        UPDATE dbo.Conta SET Saldo = Saldo - @Valor WHERE Id = @ContaOrigemId;
        UPDATE dbo.Conta SET Saldo = Saldo + @Valor WHERE Id = @ContaDestinoId;

        INSERT INTO dbo.Transacao (IdConta, Tipo, Valor, Descricao)
        VALUES
        (@ContaOrigemId, 'TRANSFERENCIA_SAIDA', @Valor, 'Transferencia enviada'),
        (@ContaDestinoId, 'TRANSFERENCIA_ENTRADA', @Valor, 'Transferencia recebida');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_RegistrarAuditoriaDiaria
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AuditoriaOperacao (Entidade, Operacao, Detalhes)
    SELECT 'Conta', 'AUDITORIA_DIARIA', CONCAT('Conta ', Numero, ' com saldo ', Saldo)
    FROM dbo.Conta;
END;
GO
