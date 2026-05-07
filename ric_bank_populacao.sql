USE RicBank;
GO

INSERT INTO dbo.Agencia (Numero, Nome, Cidade, UF)
VALUES
('0001', 'Agencia Centro', 'Joao Pessoa', 'PB'),
('0002', 'Agencia Manaira', 'Joao Pessoa', 'PB'),
('0003', 'Agencia Campina', 'Campina Grande', 'PB');
GO

INSERT INTO dbo.Cliente (Nome, CPF, DataNascimento, Telefone, Email, Cidade, UF)
VALUES
('Ana Costa', '11111111111', '1998-02-10', '83999990001', 'ana@ricbank.com', 'Joao Pessoa', 'PB'),
('Bruno Lima', '22222222222', '1997-05-21', '83999990002', 'bruno@ricbank.com', 'Joao Pessoa', 'PB'),
('Carla Sousa', '33333333333', '1999-07-13', '83999990003', 'carla@ricbank.com', 'Cabedelo', 'PB'),
('Diego Alves', '44444444444', '1996-09-30', '83999990004', 'diego@ricbank.com', 'Campina Grande', 'PB'),
('Erika Melo', '55555555555', '2000-12-02', '83999990005', 'erika@ricbank.com', 'Joao Pessoa', 'PB');
GO

INSERT INTO dbo.Conta (ClienteId, AgenciaId, Numero, Tipo, Saldo, Status)
SELECT
    c.Id,
    a.Id,
    dados.Numero,
    dados.Tipo,
    dados.Saldo,
    dados.Status
FROM
(
    VALUES
        ('11111111111', '0001', '10001-0', 'CORRENTE', 2500.00, 'ATIVA'),
        ('22222222222', '0001', '10002-8', 'POUPANCA', 870.00, 'ATIVA'),
        ('33333333333', '0002', '10003-6', 'CORRENTE', 6400.00, 'ATIVA'),
        ('44444444444', '0003', '10004-4', 'SALARIO', 1320.50, 'ATIVA'),
        ('55555555555', '0002', '10005-2', 'CORRENTE', 9800.75, 'ATIVA')
) AS dados (CPF, AgenciaNumero, Numero, Tipo, Saldo, Status)
INNER JOIN dbo.Cliente AS c
    ON c.CPF = dados.CPF
INNER JOIN dbo.Agencia AS a
    ON a.Numero = dados.AgenciaNumero;
GO

INSERT INTO dbo.Cartao (ClienteId, ContaId, Numero, Tipo, Limite, DataValidade, Status)
SELECT
    c.Id,
    ct.Id,
    dados.Numero,
    dados.Tipo,
    dados.Limite,
    dados.DataValidade,
    dados.Status
FROM
(
    VALUES
        ('11111111111', '10001-0', '5000000000000001', 'CREDITO', 3000.00, '2028-12-31', 'ATIVO'),
        ('22222222222', '10002-8', '5000000000000002', 'DEBITO', 0.00, '2027-10-31', 'ATIVO'),
        ('33333333333', '10003-6', '5000000000000003', 'CREDITO', 8000.00, '2029-06-30', 'ATIVO'),
        ('55555555555', '10005-2', '5000000000000005', 'MULTIPLO', 5000.00, '2028-08-31', 'ATIVO')
) AS dados (CPF, ContaNumero, Numero, Tipo, Limite, DataValidade, Status)
INNER JOIN dbo.Cliente AS c
    ON c.CPF = dados.CPF
INNER JOIN dbo.Conta AS ct
    ON ct.Numero = dados.ContaNumero
   AND ct.ClienteId = c.Id;
GO

INSERT INTO dbo.Transacao (ContaId, Tipo, Valor, DataTransacao, Descricao)
SELECT
    ct.Id,
    dados.Tipo,
    dados.Valor,
    DATEADD(DAY, -dados.DiasAtras, GETDATE()),
    dados.Descricao
FROM
(
    VALUES
        ('10001-0', 'DEPOSITO', 500.00, 10, 'Deposito inicial'),
        ('10001-0', 'PAGAMENTO', 120.00, 8, 'Pagamento de boleto'),
        ('10002-8', 'SAQUE', 50.00, 7, 'Saque em caixa eletronico'),
        ('10003-6', 'DEPOSITO', 1500.00, 6, 'Transferencia recebida'),
        ('10003-6', 'TRANSFERENCIA_SAIDA', 300.00, 5, 'Transferencia enviada'),
        ('10004-4', 'DEPOSITO', 1320.50, 4, 'Credito salarial'),
        ('10005-2', 'PAGAMENTO', 800.00, 3, 'Pagamento de fatura'),
        ('10005-2', 'DEPOSITO', 2500.00, 1, 'TED recebida')
) AS dados (ContaNumero, Tipo, Valor, DiasAtras, Descricao)
INNER JOIN dbo.Conta AS ct
    ON ct.Numero = dados.ContaNumero;
GO

INSERT INTO dbo.Emprestimo (ClienteId, ValorSolicitado, TaxaJuros, QuantidadeParcelas, Status)
SELECT
    c.Id,
    dados.ValorSolicitado,
    dados.TaxaJuros,
    dados.QuantidadeParcelas,
    dados.Status
FROM
(
    VALUES
        ('11111111111', 5000.00, 1.80, 12, 'APROVADO'),
        ('33333333333', 12000.00, 2.10, 24, 'EM_ANALISE'),
        ('44444444444', 3000.00, 1.50, 10, 'APROVADO')
) AS dados (CPF, ValorSolicitado, TaxaJuros, QuantidadeParcelas, Status)
INNER JOIN dbo.Cliente AS c
    ON c.CPF = dados.CPF;
GO
