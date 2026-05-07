USE RicBank;
GO

-- Contas ordenadas da maior para a menor saldo.
SELECT
    ag.Numero,
    ag.Nome,
    co.Numero,
    co.Saldo
FROM dbo.Conta AS co WITH (NOLOCK)
INNER JOIN dbo.Agencia AS ag WITH (NOLOCK)
    ON ag.Id = co.AgenciaId
ORDER BY co.Saldo DESC;
GO

CREATE TABLE dbo.TipoLancamento (
    Id TINYINT NOT NULL,
    Nome VARCHAR(50) NOT NULL,

    CONSTRAINT PK_IdTipoLancamento PRIMARY KEY (Id),
);
GO

CREATE TABLE dbo.OrigemLancamento (
    Id TINYINT NOT NULL,
    Nome VARCHAR(50) NOT NULL,

    CONSTRAINT PK_IdOrigemLancamento PRIMARY KEY (Id),
);
GO

CREATE TABLE dbo.Lancamento (
    Id INT IDENTITY(1, 1),
    ContaId INT NOT NULL,
    IdTipoLancamento TINYINT NOT NULL,
    IdOrigemLancamento TINYINT NOT NULL,
    DataHora DATETIME NOT NULL DEFAULT GETDATE(),
    Valor DECIMAL(18,2) NOT NULL,
    DebitoOuCredito CHAR(1) NOT NULL,
    Descricao VARCHAR(150) NOT NULL,

    CONSTRAINT PK_IdLancamento PRIMARY KEY (Id),
    CONSTRAINT FK_IdConta_Lancamento FOREIGN KEY (IdConta) REFERENCES dbo.Conta(Id),
    CONSTRAINT FK_IdOrigemLancamento_Lancamento FOREIGN KEY (IdOrigemLancamento) REFERENCES dbo.OrigemLancamento(Id),
    CONSTRAINT FK_IdTipoLancamento_Lancamento FOREIGN KEY (IdTipoLancamento) REFERENCES dbo.TipoLancamento(Id),
);
GO

CREATE INDEX IDX_IdContaDataHora_Lancamento
    ON dbo.Lancamento   (
                            ContaId, 
                            DataHora
                        );
GO

CREATE INDEX IDX_IdOrigemLancamento_Lancamento
    ON dbo.Lancamento (OrigemLancamentoId);
GO

CREATE INDEX IDX_IdTipoLancamento_Lancamento
    ON dbo.Lancamento (TipoLancamentoId);
GO
