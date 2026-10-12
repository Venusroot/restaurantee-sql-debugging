# 🕵️ Operação Prato Limpo: auditoria e correção do banco Restaurantee

Projeto acadêmico de **modelagem e depuração de banco de dados SQL**, desenvolvido em grupo no curso de **Desenvolvimento de Software Multiplataforma (DSM) da Fatec Mauá**.

## 📌 Sobre a atividade

O professor propôs a cada aluno criar **dois bancos de dados** para um restaurante:

1. **Um banco correto**, sem problemas.
2. **Um banco com problemas**, com no mínimo **5 tabelas** e **20 erros** introduzidos de propósito.

Depois, os alunos **trocaram os bancos entre si**, e cada grupo recebeu o banco com problemas de outro colega. O desafio foi **encontrar os erros, corrigi-los e explicar o raciocínio**.

Para a apresentação, criamos uma narrativa de **auditoria**: quatro "inspetores" (um por integrante, cada um com uma cor) fiscalizam o banco do restaurante, apontam as infrações e entregam a correção.

## 🎯 Objetivos

- Identificar e classificar erros em um script SQL.
- Corrigir problemas de tipos de dados, chaves e relacionamentos.
- Validar a solução com dados de exemplo e consultas.
- Comunicar o raciocínio técnico de forma clara e didática.

## 🗂️ Modelo do banco

Banco **Restaurantee**, com 5 tabelas:

| Tabela | Descrição |
|---|---|
| `Pratoss` | Cardápio do restaurante |
| `Clientess` | Clientes cadastrados |
| `Funcionarioss` | Funcionários |
| `Pedidoss` | Pedidos (referencia cliente e funcionário) |
| `ItensPedidoo` | Itens de cada pedido (referencia pedido e prato) |

> Os nomes das tabelas (com letras duplicadas) foram mantidos como no enunciado original.

```
Clientess ──┐
            ├──< Pedidoss ──< ItensPedidoo >── Pratoss
Funcionarioss ┘
```

## 🔍 Resumo das 20 infrações encontradas

| Tipo de erro | Qtde | Exemplo |
|---|---|---|
| Tipo de dados incorreto | 14 | `preco varchar(10)` → `decimal(10,2)` |
| Chave primária ausente | 1 | `Pratoss` sem `PRIMARY KEY` |
| Chave estrangeira ausente | 2 | `Pedidoss` e `ItensPedidoo` sem `FOREIGN KEY` |
| Tipo incompatível na chave estrangeira | 1 | `idCliente varchar(5)` → `int` |
| Nomenclatura (erro de digitação) | 1 | `idPedida` → `idPedido` |
| Lógica de cálculo | 1 | `qtd * precoUnit + desconto` → `(qtd * precoUnit) - desconto` |

<details>
<summary>Ver a lista completa das 20 infrações</summary>

| # | Local | Antes | Depois |
|---|---|---|---|
| 1 | `Pratoss.idPrato` | sem PK | `PRIMARY KEY` |
| 2 | `Pratoss.preco` | `varchar(10)` | `decimal(10,2)` |
| 3 | `Pratoss.tempoPreparo` | `date` | `time` |
| 4 | `Clientess.nome` | `date` | `varchar(100)` |
| 5 | `Clientess.email` | `numeric` | `varchar(100)` |
| 6 | `Clientess.dataNascimento` | `varchar(20)` | `date` |
| 7 | `Clientess.estado` | `int` | `char(2)` |
| 8 | `Funcionarioss.nome` | `int` | `varchar(100)` |
| 9 | `Funcionarioss.cpf` | `int` | `char(11)` |
| 10 | `Funcionarioss.salario` | `int` | `decimal(10,2)` |
| 11 | `Funcionarioss.dataAdmissao` | `int` | `date` |
| 12 | `Pedidoss.idPedida` | `idPedida` | `idPedido` |
| 13 | `Pedidoss.idCliente` e `ItensPedidoo.idPedido` | `varchar(5)` | `int` |
| 14 | `Pedidoss` (relacionamentos) | sem FK | FKs para `Clientess` e `Funcionarioss` |
| 15 | `Pedidoss.horaPedido` | `date` | `datetime DEFAULT GETDATE()` |
| 16 | `Pedidoss.valorTotal` | `time` | `decimal(10,2)` |
| 17 | `ItensPedidoo.qtd` | `varchar(10)` | `int` |
| 18 | `ItensPedidoo.desconto` | `time` | `decimal(10,2)` |
| 19 | `ItensPedidoo.subtotal` | `qtd * precoUnit + desconto` | `(qtd * precoUnit) - desconto` |
| 20 | `ItensPedidoo` (relacionamentos) | sem FK | FKs para `Pedidoss` e `Pratoss` |

</details>

## 📁 Arquivos do repositório

| Arquivo | Conteúdo |
|---|---|
| `restaurantee_sqlserver.sql` | Versão corrigida para **SQL Server (T-SQL)**: estrutura comentada, dados de exemplo, consultas de validação e testes de rejeição com `TRY/CATCH` |
| `restaurantee_mysql_online.sql` | Versão equivalente para **MySQL 8**, pensada para rodar em compiladores online |

Em ambos os scripts, cada linha alterada traz um comentário `[CORRIGIDO #n]` com o **antes**, o **depois** e o **motivo**, usando a mesma numeração das 20 infrações.

## ▶️ Como executar

**SQL Server**
1. Abra o `restaurantee_sqlserver.sql` no SQL Server Management Studio (SSMS).
2. Execute o script completo. Ele cria o banco, apaga tabelas antigas com os mesmos nomes (cuidado se houver dados), recria a estrutura, insere os dados e roda as consultas e os testes.
3. Compare os resultados com os valores esperados indicados nos comentários.

**Compilador online (MySQL)**
1. Cole o conteúdo de `restaurantee_mysql_online.sql` em um compilador MySQL (por exemplo, OneCompiler ou DB Fiddle).
2. Se o compilador bloquear `CREATE DATABASE`, mantenha as duas linhas comentadas, como já estão.
3. Para os testes de rejeição (seção 4), descomente e rode **um por vez**, pois um erro interrompe o script.

## ✅ O que a validação demonstra

- O CPF `01234567890` **mantém o zero à esquerda** (`char(11)`).
- O salário `2150.75` **mantém os centavos** (`decimal`).
- O subtotal de 3 × R$ 20,00 − R$ 5,00 resulta em **R$ 55,00**, e não R$ 65,00.
- O `valorTotal` de cada pedido **bate com a soma dos subtotais** dos itens.
- O banco **recusa** pedidos de clientes inexistentes, datas inválidas (31/02), quantidade em texto e estado com mais de 2 letras.

## 🧠 Aprendizados

- **Tipo certo para cada dado:** valor em `decimal`, data em `date`, texto em `varchar`.
- **Chaves e relacionamentos** garantem a integridade, e a chave estrangeira deve ter o mesmo tipo da chave primária.
- **Erros silenciosos são os mais perigosos:** quase todo o script original executava, mas o modelo era inutilizável.
- Depurar exige **ler, classificar, corrigir e testar**, e não apenas "fazer rodar".

## 🛠️ Tecnologias

SQL · SQL Server (T-SQL) · MySQL 8

**Instituição:** Fatec Mauá · Curso de Desenvolvimento de Software Multiplataforma
