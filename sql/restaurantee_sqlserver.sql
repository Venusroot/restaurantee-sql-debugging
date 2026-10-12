/* =====================================================================
   OPERACAO PRATO LIMPO - Banco Restaurantee (versao corrigida e comentada)
   SGBD: SQL Server (T-SQL)  |  Fatec Maua - DSM
   Como ler: cada linha comentada [CORRIGIDO #n] mostra o ANTES, o DEPOIS e o MOTIVO.
   O numero #n e o mesmo da infracao (1 a 20) apresentada nos slides.
   Observacao: este script NAO foi executado em um SQL Server por quem o gerou;
   revise e rode primeiro em ambiente de teste.
   ===================================================================== */

-- Cria o banco somente se ele ainda nao existir (permite rodar o script varias vezes)
IF DB_ID('Restaurantee') IS NULL
    CREATE DATABASE Restaurantee;
GO

USE Restaurantee;
GO

-- Reinicio: apaga as tabelas (inclusive as do codigo ERRADO, se ja foram criadas).
-- Ordem inversa de dependencia: primeiro quem tem FK, por ultimo quem e referenciado.
DROP TABLE IF EXISTS ItensPedidoo;
DROP TABLE IF EXISTS Pedidoss;
DROP TABLE IF EXISTS Funcionarioss;
DROP TABLE IF EXISTS Clientess;
DROP TABLE IF EXISTS Pratoss;
GO

-- ===================== 1) ESTRUTURA (CREATE TABLE) =====================

CREATE TABLE Pratoss (
    -- [CORRIGIDO #1] antes: sem PRIMARY KEY | depois: PRIMARY KEY. Sem chave primaria havia pratos duplicados e nenhuma FK podia apontar para a tabela.
    idPrato         int           IDENTITY(1,1) PRIMARY KEY,
    nome            varchar(60),
    descricao       varchar(100),
    -- [CORRIGIDO #2] antes: varchar(10) | depois: decimal(10,2). Texto nao soma nem calcula; decimal guarda valor com 2 casas.
    preco           decimal(10,2),
    categoria       varchar(50),
    disponibilidade int,           -- significado assumido: 1 = disponivel, 0 = indisponivel (confirmar com o professor)
    -- [CORRIGIDO #3] antes: date | depois: time. Tempo de preparo e duracao, nao dia do calendario. Alternativa: int em minutos.
    tempoPreparo    time,
    dataCadastro    date
);
GO

CREATE TABLE Clientess (
    idCliente       int           IDENTITY(1,1) PRIMARY KEY,
    -- [CORRIGIDO #4] antes: date | depois: varchar(100). Nome e texto.
    nome            varchar(100),
    cpf             char(11),      -- char(11) preserva zeros a esquerda
    -- [CORRIGIDO #5] antes: numeric | depois: varchar(100). E-mail tem letras e @.
    email           varchar(100),
    telefone        varchar(60),
    -- [CORRIGIDO #6] antes: varchar(20) | depois: date. O tipo date so aceita datas validas.
    dataNascimento  date,
    cidade          varchar(60),
    -- [CORRIGIDO #7] antes: int | depois: char(2). UF e sigla de 2 letras, como SP.
    estado          char(2)
);
GO

CREATE TABLE Funcionarioss (
    idFuncionario   int           IDENTITY(1,1) PRIMARY KEY,
    -- [CORRIGIDO #8] antes: int | depois: varchar(100). Nome e texto.
    nome            varchar(100),
    -- [CORRIGIDO #9] antes: int | depois: char(11). CPF tem 11 digitos: estoura o int (max ~2,1 bilhoes) e perderia zeros a esquerda.
    cpf             char(11),
    email           varchar(100),
    telefone        varchar(60),
    cargo           varchar(60),
    -- [CORRIGIDO #10] antes: int | depois: decimal(10,2). int corta os centavos do salario.
    salario         decimal(10,2),
    -- [CORRIGIDO #11] antes: int | depois: date. Admissao e uma data.
    dataAdmissao    date
);
GO

CREATE TABLE Pedidoss (
    -- [CORRIGIDO #12] antes: idPedida | depois: idPedido. Erro de digitacao: as outras tabelas referenciam idPedido.
    idPedido        int           IDENTITY(1,1) PRIMARY KEY,
    -- [CORRIGIDO #13] antes: varchar(5) | depois: int. A FK precisa ter o mesmo tipo da PK que referencia (Clientess.idCliente e int).
    idCliente       int,
    idFuncionario   int,
    -- [CORRIGIDO #15] antes: date | depois: datetime DEFAULT GETDATE(). date perdia a hora; datetime guarda dia e hora e o DEFAULT preenche automaticamente. Se o professor exigir time, use time.
    horaPedido      datetime      DEFAULT GETDATE(),
    statusPedido    varchar(60),
    pagamento       varchar(60),
    -- [CORRIGIDO #16] antes: time | depois: decimal(10,2). Valor monetario nao e horario.
    valorTotal      decimal(10,2),
    observacao      varchar(200),
    -- [CORRIGIDO #14] antes: nenhuma FOREIGN KEY | depois: duas FOREIGN KEY. Garante que o pedido so exista para cliente e funcionario cadastrados.
    FOREIGN KEY (idCliente)     REFERENCES Clientess(idCliente),
    FOREIGN KEY (idFuncionario) REFERENCES Funcionarioss(idFuncionario)
);
GO

CREATE TABLE ItensPedidoo (
    idItem          int           IDENTITY(1,1) PRIMARY KEY,
    -- [CORRIGIDO #13] antes: varchar(5) | depois: int. Mesma regra: a FK idPedido deve ter o tipo de Pedidoss.idPedido.
    idPedido        int,
    idPrato         int,
    -- [CORRIGIDO #17] antes: varchar(10) | depois: int. Quantidade e numero inteiro; texto aceitaria valores como abc.
    qtd             int,
    precoUnit       decimal(10,2), -- copia o preco do prato na hora da venda (preserva o historico)
    -- [CORRIGIDO #18] antes: time | depois: decimal(10,2). Desconto e valor em reais, nao horario.
    desconto        decimal(10,2),
    -- [CORRIGIDO #19] antes: qtd * precoUnit + desconto | depois: (qtd * precoUnit) - desconto. O desconto deve ser subtraido, nao somado. Ex.: 3 x 20,00 - 5,00 = 55,00 (antes dava 65,00).
    subtotal        AS ((qtd * precoUnit) - desconto),
    observacao      varchar(200),
    -- [CORRIGIDO #20] antes: nenhuma FOREIGN KEY | depois: duas FOREIGN KEY. Cada item precisa apontar para um pedido e um prato existentes.
    FOREIGN KEY (idPedido) REFERENCES Pedidoss(idPedido),
    FOREIGN KEY (idPrato)  REFERENCES Pratoss(idPrato)
);
GO

-- ===================== 2) DADOS DE EXEMPLO (INSERT) =====================
-- (Dados em ASCII, sem acentos, para evitar problemas de codificacao no SSMS.)

-- Pratos (cardapio). disponibilidade: 1 = disponivel, 0 = indisponivel (suposicao nossa)
INSERT INTO Pratoss (nome, descricao, preco, categoria, disponibilidade, tempoPreparo, dataCadastro) VALUES
('Feijoada Completa', 'Feijoada com arroz, couve e farofa', 45.90, 'Prato principal', 1, '00:40:00', '2026-01-10'),
('Risoto de Cogumelos', 'Risoto cremoso com cogumelos frescos', 38.50, 'Prato principal', 1, '00:30:00', '2026-01-10'),
('Salada Caprese', 'Tomate, mussarela de bufala e manjericao', 20.00, 'Entrada', 1, '00:10:00', '2026-01-12'),
('Suco de Laranja', 'Suco natural 400 ml', 9.90, 'Bebida', 1, '00:05:00', '2026-01-12'),
('Pudim de Leite', 'Pudim caseiro com calda de caramelo', 14.00, 'Sobremesa', 0, '00:15:00', '2026-02-01');

-- Clientes (CPFs ficticios; o primeiro comeca com zero para provar que char(11) preserva o zero)
INSERT INTO Clientess (nome, cpf, email, telefone, dataNascimento, cidade, estado) VALUES
('Ana Souza', '01234567890', 'ana.souza@email.com', '(11) 91234-5678', '1995-04-12', 'Maua', 'SP'),
('Bruno Lima', '98765432100', 'bruno.lima@email.com', '(11) 99876-5432', '1988-11-30', 'Santo Andre', 'SP'),
('Carla Mendes', '11122233344', 'carla.mendes@email.com', '(21) 98765-4321', '2000-07-05', 'Rio de Janeiro', 'RJ'),
('Diego Rocha', '55566677788', 'diego.rocha@email.com', '(31) 97654-3210', '1992-01-20', 'Belo Horizonte', 'MG');

-- Funcionarios (salario com centavos; CPF do primeiro comeca com zeros)
INSERT INTO Funcionarioss (nome, cpf, email, telefone, cargo, salario, dataAdmissao) VALUES
('Marcos Pereira', '00011122233', 'marcos@restaurantee.com', '(11) 94444-1111', 'Garcom', 2150.75, '2024-03-01'),
('Juliana Alves', '22233344455', 'juliana@restaurantee.com', '(11) 94444-2222', 'Caixa', 2800.00, '2023-08-15'),
('Roberto Nunes', '33344455566', 'roberto@restaurantee.com', '(11) 94444-3333', 'Gerente', 5200.50, '2021-05-10');

-- Pedidos (valorTotal comeca em 0 e sera calculado a partir dos itens mais abaixo)
INSERT INTO Pedidoss (idCliente, idFuncionario, horaPedido, statusPedido, pagamento, valorTotal, observacao) VALUES
(1, 1, '2026-03-10T12:30:00', 'Entregue', 'Pix', 0, 'Sem cebola'),
(2, 1, '2026-03-10T13:10:00', 'Entregue', 'Cartao', 0, NULL),
(3, 2, '2026-03-11T19:45:00', 'Em preparo', 'Dinheiro', 0, 'Mesa 7');

-- Pedido 4 NAO informa horaPedido: o DEFAULT preenche com a data e hora atuais
INSERT INTO Pedidoss (idCliente, idFuncionario, statusPedido, pagamento, valorTotal, observacao) VALUES
(1, 2, 'Aberto', 'Cartao', 0, NULL);

-- Itens dos pedidos (o subtotal NAO e informado: o banco calcula qtd * precoUnit - desconto)
INSERT INTO ItensPedidoo (idPedido, idPrato, qtd, precoUnit, desconto, observacao) VALUES
(1, 1, 1, 45.90, 0.00, NULL),
(1, 4, 2, 9.90, 0.00, 'Sem gelo'),
(2, 3, 3, 20.00, 5.00, 'Desconto de grupo'),
(2, 2, 1, 38.50, 0.00, NULL),
(3, 2, 2, 38.50, 3.50, NULL),
(3, 4, 1, 9.90, 0.00, NULL),
(4, 1, 1, 45.90, 0.00, NULL),
(4, 3, 1, 20.00, 0.00, NULL);

-- Calcula o valorTotal de cada pedido somando os subtotais dos itens
UPDATE Pedidoss
SET valorTotal = (SELECT SUM(i.subtotal) FROM ItensPedidoo i WHERE i.idPedido = Pedidoss.idPedido)
WHERE idPedido > 0;
GO

-- ===================== 3) VALIDACAO: CONSULTAS =====================

-- Consulta 1: o cardapio com precos numericos
-- Esperado: 5 linhas; Feijoada = 45.90, Pudim = 14.00 (preco agora e decimal e pode ser somado)
SELECT idPrato, nome, preco, tempoPreparo FROM Pratoss;

-- Consulta 2: CPFs preservam o zero a esquerda e estado tem 2 letras
-- Esperado: Ana Souza | 01234567890 | SP   (o zero inicial NAO foi perdido)
SELECT nome, cpf, dataNascimento, cidade, estado FROM Clientess;

-- Consulta 3: salario com centavos
-- Esperado: Marcos Pereira = 2150.75 (antes, com int, viraria 2150)
SELECT nome, cpf, cargo, salario, dataAdmissao FROM Funcionarioss;

-- Consulta 4: itens com o subtotal calculado pelo banco (qtd * precoUnit - desconto)
-- Esperado (destaque o item 3: 3 x 20.00 - 5.00 = 55.00; antes o codigo daria 65.00):
--   idItem | idPedido | prato               | qtd | precoUnit | desconto | subtotal
--   1      | 1        | Feijoada Completa   | 1   | 45.90     | 0.00     | 45.90   
--   2      | 1        | Suco de Laranja     | 2   | 9.90      | 0.00     | 19.80   
--   3      | 2        | Salada Caprese      | 3   | 20.00     | 5.00     | 55.00   
--   4      | 2        | Risoto de Cogumelos | 1   | 38.50     | 0.00     | 38.50   
--   5      | 3        | Risoto de Cogumelos | 2   | 38.50     | 3.50     | 73.50   
--   6      | 3        | Suco de Laranja     | 1   | 9.90      | 0.00     | 9.90    
--   7      | 4        | Feijoada Completa   | 1   | 45.90     | 0.00     | 45.90   
--   8      | 4        | Salada Caprese      | 1   | 20.00     | 0.00     | 20.00   
SELECT i.idItem, i.idPedido, pr.nome AS prato, i.qtd, i.precoUnit, i.desconto, i.subtotal
FROM ItensPedidoo i
JOIN Pratoss pr ON pr.idPrato = i.idPrato
ORDER BY i.idItem;

-- Consulta 5: pedidos com cliente, atendente e conferencia do total (JOIN entre as 5 tabelas)
-- Esperado (valorTotal igual a soma dos itens em todos os pedidos):
--   idPedido | cliente      | atendente      | valorTotal | soma_itens
--   1        | Ana Souza    | Marcos Pereira | 65.70      | 65.70     
--   2        | Bruno Lima   | Marcos Pereira | 93.50      | 93.50     
--   3        | Carla Mendes | Juliana Alves  | 83.40      | 83.40     
--   4        | Ana Souza    | Juliana Alves  | 65.90      | 65.90     
SELECT p.idPedido, c.nome AS cliente, f.nome AS atendente, p.valorTotal, SUM(i.subtotal) AS soma_itens
FROM Pedidoss p
JOIN Clientess c ON c.idCliente = p.idCliente
JOIN Funcionarioss f ON f.idFuncionario = p.idFuncionario
JOIN ItensPedidoo i ON i.idPedido = p.idPedido
GROUP BY p.idPedido, c.nome, f.nome, p.valorTotal
ORDER BY p.idPedido;
GO

-- ===================== 4) VALIDACAO: O BANCO AGORA RECUSA DADOS INVALIDOS =====================
-- Cada bloco TENTA inserir algo errado. O esperado e cair no CATCH (o banco recusou).

BEGIN TRY  -- Teste A: pedido de cliente que NAO existe (FK, corrige #14)
    INSERT INTO Pedidoss (idCliente, idFuncionario, statusPedido, pagamento, valorTotal) VALUES (999, 1, 'Aberto', 'Pix', 0);
    PRINT 'FALHA NO TESTE A: o banco aceitou um pedido de cliente inexistente!';
END TRY
BEGIN CATCH PRINT 'Teste A OK, o banco recusou: ' + ERROR_MESSAGE(); END CATCH;

BEGIN TRY  -- Teste B: item de pedido que NAO existe (FK, corrige #20)
    INSERT INTO ItensPedidoo (idPedido, idPrato, qtd, precoUnit, desconto) VALUES (999, 1, 1, 10.00, 0);
    PRINT 'FALHA NO TESTE B: o banco aceitou item de pedido inexistente!';
END TRY
BEGIN CATCH PRINT 'Teste B OK, o banco recusou: ' + ERROR_MESSAGE(); END CATCH;

BEGIN TRY  -- Teste C: data de nascimento invalida (date, corrige #6)
    INSERT INTO Clientess (nome, cpf, email, dataNascimento, estado) VALUES ('Teste', '00000000000', 't@t.com', '2024-02-31', 'SP');
    PRINT 'FALHA NO TESTE C: o banco aceitou 31/02!';
END TRY
BEGIN CATCH PRINT 'Teste C OK, o banco recusou: ' + ERROR_MESSAGE(); END CATCH;

BEGIN TRY  -- Teste D: quantidade em texto (int, corrige #17)
    INSERT INTO ItensPedidoo (idPedido, idPrato, qtd, precoUnit, desconto) VALUES (1, 1, 'abc', 10.00, 0);
    PRINT 'FALHA NO TESTE D: o banco aceitou qtd = abc!';
END TRY
BEGIN CATCH PRINT 'Teste D OK, o banco recusou: ' + ERROR_MESSAGE(); END CATCH;

BEGIN TRY  -- Teste E: estado com 3 letras (char(2), corrige #7)
    INSERT INTO Clientess (nome, cpf, email, dataNascimento, estado) VALUES ('Teste', '00000000001', 't@t.com', '2000-01-01', 'SPP');
    PRINT 'FALHA NO TESTE E: o banco aceitou estado com 3 letras!';
END TRY
BEGIN CATCH PRINT 'Teste E OK, o banco recusou: ' + ERROR_MESSAGE(); END CATCH;

BEGIN TRY  -- Teste F: apagar cliente que tem pedidos (FK protege a integridade)
    DELETE FROM Clientess WHERE idCliente = 1;
    PRINT 'FALHA NO TESTE F: o banco apagou um cliente com pedidos!';
END TRY
BEGIN CATCH PRINT 'Teste F OK, o banco recusou: ' + ERROR_MESSAGE(); END CATCH;
GO
-- Fim. Se as consultas 1 a 5 retornaram o esperado e os testes A a F imprimiram "OK", o modelo funciona.
