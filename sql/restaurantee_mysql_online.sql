/* =====================================================================
   OPERACAO PRATO LIMPO - Banco Restaurantee (versao corrigida e comentada)
   Versao para COMPILADOR ONLINE: MySQL 8 (ex.: OneCompiler, DB Fiddle, MySQL Workbench)
   Fatec Maua - DSM. O numero [CORRIGIDO #n] e o mesmo da infracao nos slides.
   Diferencas para o SQL Server: AUTO_INCREMENT no lugar de IDENTITY(1,1),
   CURRENT_TIMESTAMP no lugar de GETDATE(), coluna calculada com GENERATED ALWAYS ... STORED
   e sem GO / TRY-CATCH. Este script NAO foi executado em um MySQL por quem o gerou;
   a logica dos dados e das consultas foi conferida em outro SGBD (SQLite).
   ===================================================================== */

-- Alguns compiladores online ja entregam um banco pronto e bloqueiam CREATE DATABASE.
-- Se for rodar no seu MySQL, remova os dois "--" abaixo:
-- CREATE DATABASE IF NOT EXISTS Restaurantee;
-- USE Restaurantee;

-- Reinicio: apaga tabelas antigas (ordem inversa de dependencia)
DROP TABLE IF EXISTS ItensPedidoo;
DROP TABLE IF EXISTS Pedidoss;
DROP TABLE IF EXISTS Funcionarioss;
DROP TABLE IF EXISTS Clientess;
DROP TABLE IF EXISTS Pratoss;

-- ===================== 1) ESTRUTURA (CREATE TABLE) =====================

CREATE TABLE Pratoss (
    -- [CORRIGIDO #1] antes: sem PRIMARY KEY | depois: PRIMARY KEY. Evita pratos duplicados e permite FK.
    idPrato         INT           AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(60),
    descricao       VARCHAR(100),
    -- [CORRIGIDO #2] antes: varchar(10) | depois: DECIMAL(10,2). Valor monetario precisa ser numerico.
    preco           DECIMAL(10,2),
    categoria       VARCHAR(50),
    disponibilidade INT,           -- assumido: 1 = disponivel, 0 = indisponivel
    -- [CORRIGIDO #3] antes: date | depois: TIME. Tempo de preparo e duracao.
    tempoPreparo    TIME,
    dataCadastro    DATE
);

CREATE TABLE Clientess (
    idCliente       INT           AUTO_INCREMENT PRIMARY KEY,
    -- [CORRIGIDO #4] antes: date | depois: VARCHAR(100). Nome e texto.
    nome            VARCHAR(100),
    cpf             CHAR(11),
    -- [CORRIGIDO #5] antes: numeric | depois: VARCHAR(100). E-mail e texto.
    email           VARCHAR(100),
    telefone        VARCHAR(60),
    -- [CORRIGIDO #6] antes: varchar(20) | depois: DATE. So aceita datas validas.
    dataNascimento  DATE,
    cidade          VARCHAR(60),
    -- [CORRIGIDO #7] antes: int | depois: CHAR(2). UF e sigla de 2 letras.
    estado          CHAR(2)
);

CREATE TABLE Funcionarioss (
    idFuncionario   INT           AUTO_INCREMENT PRIMARY KEY,
    -- [CORRIGIDO #8] antes: int | depois: VARCHAR(100). Nome e texto.
    nome            VARCHAR(100),
    -- [CORRIGIDO #9] antes: int | depois: CHAR(11). CPF tem 11 digitos e pode comecar com zero.
    cpf             CHAR(11),
    email           VARCHAR(100),
    telefone        VARCHAR(60),
    cargo           VARCHAR(60),
    -- [CORRIGIDO #10] antes: int | depois: DECIMAL(10,2). Preserva os centavos.
    salario         DECIMAL(10,2),
    -- [CORRIGIDO #11] antes: int | depois: DATE. Admissao e uma data.
    dataAdmissao    DATE
);

CREATE TABLE Pedidoss (
    -- [CORRIGIDO #12] antes: idPedida | depois: idPedido. Erro de digitacao.
    idPedido        INT           AUTO_INCREMENT PRIMARY KEY,
    -- [CORRIGIDO #13] antes: varchar(5) | depois: INT. FK com o mesmo tipo da PK referenciada.
    idCliente       INT,
    idFuncionario   INT,
    -- [CORRIGIDO #15] antes: date | depois: DATETIME DEFAULT CURRENT_TIMESTAMP. Guarda dia e hora; o DEFAULT preenche automaticamente.
    horaPedido      DATETIME      DEFAULT CURRENT_TIMESTAMP,
    statusPedido    VARCHAR(60),
    pagamento       VARCHAR(60),
    -- [CORRIGIDO #16] antes: time | depois: DECIMAL(10,2). Valor monetario.
    valorTotal      DECIMAL(10,2),
    observacao      VARCHAR(200),
    -- [CORRIGIDO #14] antes: nenhuma FOREIGN KEY | depois: duas FOREIGN KEY. Integridade com clientes e funcionarios.
    FOREIGN KEY (idCliente)     REFERENCES Clientess(idCliente),
    FOREIGN KEY (idFuncionario) REFERENCES Funcionarioss(idFuncionario)
);

CREATE TABLE ItensPedidoo (
    idItem          INT           AUTO_INCREMENT PRIMARY KEY,
    -- [CORRIGIDO #13] antes: varchar(5) | depois: INT. Mesmo tipo de Pedidoss.idPedido.
    idPedido        INT,
    idPrato         INT,
    -- [CORRIGIDO #17] antes: varchar(10) | depois: INT. Quantidade e inteiro.
    qtd             INT,
    precoUnit       DECIMAL(10,2),
    -- [CORRIGIDO #18] antes: time | depois: DECIMAL(10,2). Desconto e valor em reais.
    desconto        DECIMAL(10,2),
    -- [CORRIGIDO #19] antes: qtd * precoUnit + desconto | depois: (qtd * precoUnit) - desconto. Desconto se subtrai. Ex.: 3 x 20,00 - 5,00 = 55,00.
    subtotal        DECIMAL(12,2) GENERATED ALWAYS AS ((qtd * precoUnit) - desconto) STORED,
    observacao      VARCHAR(200),
    -- [CORRIGIDO #20] antes: nenhuma FOREIGN KEY | depois: duas FOREIGN KEY. Item aponta para pedido e prato existentes.
    FOREIGN KEY (idPedido) REFERENCES Pedidoss(idPedido),
    FOREIGN KEY (idPrato)  REFERENCES Pratoss(idPrato)
);

-- ===================== 2) DADOS DE EXEMPLO (INSERT) =====================

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

-- ===================== 4) VALIDACAO: O BANCO RECUSA DADOS INVALIDOS =====================
-- Em compiladores online, um erro interrompe o script. Por isso rode UM teste por vez:
-- remova o "-- " da linha do teste e execute. Todos DEVEM dar erro (modo estrito, padrao do MySQL 8).

-- Teste A (FK, #14): pedido de cliente inexistente
-- Esperado: ERROR 1452: Cannot add or update a child row: a foreign key constraint fails
-- INSERT INTO Pedidoss (idCliente, idFuncionario, statusPedido, pagamento, valorTotal) VALUES (999, 1, 'Aberto', 'Pix', 0);

-- Teste B (FK, #20): item de pedido inexistente
-- Esperado: ERROR 1452 (foreign key constraint fails)
-- INSERT INTO ItensPedidoo (idPedido, idPrato, qtd, precoUnit, desconto) VALUES (999, 1, 1, 10.00, 0);

-- Teste C (DATE, #6): 31 de fevereiro
-- Esperado: ERROR 1292: Incorrect date value: '2024-02-31'
-- INSERT INTO Clientess (nome, cpf, email, dataNascimento, estado) VALUES ('Teste', '00000000000', 't@t.com', '2024-02-31', 'SP');

-- Teste D (INT, #17): quantidade em texto
-- Esperado: ERROR 1366: Incorrect integer value: 'abc' for column 'qtd'
-- INSERT INTO ItensPedidoo (idPedido, idPrato, qtd, precoUnit, desconto) VALUES (1, 1, 'abc', 10.00, 0);

-- Teste E (CHAR(2), #7): estado com 3 letras
-- Esperado: ERROR 1406: Data too long for column 'estado'
-- INSERT INTO Clientess (nome, cpf, email, dataNascimento, estado) VALUES ('Teste', '00000000001', 't@t.com', '2000-01-01', 'SPP');

-- Teste F (integridade): apagar cliente que tem pedidos
-- Esperado: ERROR 1451: Cannot delete or update a parent row: a foreign key constraint fails
-- DELETE FROM Clientess WHERE idCliente = 1;
