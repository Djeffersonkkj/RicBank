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
('Ana Costa',    '11111111111', '1998-02-10', '83999990001', 'ana@ricbank.com',   'Joao Pessoa',   'PB'),
('Bruno Lima',   '22222222222', '1997-05-21', '83999990002', 'bruno@ricbank.com', 'Joao Pessoa',   'PB'),
('Carla Sousa',  '33333333333', '1999-07-13', '83999990003', 'carla@ricbank.com', 'Cabedelo',      'PB'),
('Diego Alves',  '44444444444', '1996-09-30', '83999990004', 'diego@ricbank.com', 'Campina Grande','PB'),
('Erika Melo',   '55555555555', '2000-12-02', '83999990005', 'erika@ricbank.com', 'Joao Pessoa',   'PB');
GO

-- Tipo: 'C' = Corrente, 'P' = Poupanca
INSERT INTO dbo.Conta (IdCliente, IdAgencia, Numero, Tipo, Saldo, Situacao)
VALUES
(1, 1, '10001-0', 'C', 2500.00,  'ATIVA'),
(2, 1, '10002-8', 'P', 870.00,   'ATIVA'),
(3, 2, '10003-6', 'C', 6400.00,  'ATIVA'),
(4, 3, '10004-4', 'C', 1320.50,  'ATIVA'),
(5, 2, '10005-2', 'C', 9800.75,  'ATIVA');
GO

INSERT INTO dbo.Cartao (IdCliente, IdConta, Numero, Tipo, Limite, DataValidade, Situacao)
VALUES
(1, 1, '5000000000000001', 'CREDITO',  3000.00, '2028-12-31', 'ATIVO'),
(2, 2, '5000000000000002', 'DEBITO',      0.00, '2027-10-31', 'ATIVO'),
(3, 3, '5000000000000003', 'CREDITO',  8000.00, '2029-06-30', 'ATIVO'),
(5, 5, '5000000000000005', 'MULTIPLO', 5000.00, '2028-08-31', 'ATIVO');
GO

INSERT INTO dbo.Transacao (IdConta, Tipo, Valor, DataTransacao, Descricao)
VALUES
(1, 'DEPOSITO',           500.00,  DATEADD(DAY, -10, GETDATE()), 'Deposito inicial'),
(1, 'PAGAMENTO',          120.00,  DATEADD(DAY,  -8, GETDATE()), 'Pagamento de boleto'),
(2, 'SAQUE',               50.00,  DATEADD(DAY,  -7, GETDATE()), 'Saque em caixa eletronico'),
(3, 'DEPOSITO',          1500.00,  DATEADD(DAY,  -6, GETDATE()), 'Transferencia recebida'),
(3, 'TRANSFERENCIA_SAIDA', 300.00, DATEADD(DAY,  -5, GETDATE()), 'Transferencia enviada'),
(4, 'DEPOSITO',          1320.50,  DATEADD(DAY,  -4, GETDATE()), 'Credito salarial'),
(5, 'PAGAMENTO',          800.00,  DATEADD(DAY,  -3, GETDATE()), 'Pagamento de fatura'),
(5, 'DEPOSITO',          2500.00,  DATEADD(DAY,  -1, GETDATE()), 'TED recebida');
GO

INSERT INTO dbo.Emprestimo (IdCliente, ValorSolicitado, TaxaJuros, QuantidadeParcelas, Situacao)
VALUES
(1,  5000.00, 1.80, 12, 'APROVADO'),
(3, 12000.00, 2.10, 24, 'EM_ANALISE'),
(4,  3000.00, 1.50, 10, 'APROVADO');
GO
