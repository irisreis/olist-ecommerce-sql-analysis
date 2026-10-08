# Análise de E-commerce Olist com SQL e PostgreSQL

Projeto de análise exploratória de dados com o **Brazilian E-Commerce Public Dataset by Olist**, voltado a perguntas de negócio sobre vendas, clientes, logística, produtos e vendedores.

## Objetivo

Aplicar consultas SQL para investigar indicadores comerciais e operacionais de um e-commerce brasileiro. Este repositório reúne **29 análises** originalmente desenvolvidas como desafios de estudo, posteriormente revisadas, organizadas e padronizadas para publicação.

## Tecnologias

- PostgreSQL
- DBeaver
- SQL (JOIN, agregações, `FILTER`, `CASE`, CTEs, subconsultas, `RANK`, `LAG`, funções de janela e médias móveis)

## Organização

| Arquivo | Tema | Desafios originais |
| --- | --- | --- |
| `sql/01_exploracao_inicial.sql` | Pedidos, distribuição geográfica e segmentação | 01, 03, 06 |
| `sql/02_vendas_pagamentos.sql` | Formas de pagamento, faturamento e evolução mensal | 02, 12, 20, 22, 27, 28 |
| `sql/03_clientes_regioes.sql` | Clientes, recorrência e concentração de gastos | 07, 10, 16, 19 |
| `sql/04_logistica_satisfacao.sql` | Entregas, frete e satisfação | 04, 09, 13, 14, 15, 17 |
| `sql/05_produtos_vendedores.sql` | Produtos, categorias e desempenho de vendedores | 05, 08, 11, 18, 21, 23, 24, 25, 26, 29 |

## Fonte dos dados

[Brazilian E-Commerce Public Dataset by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

As consultas pressupõem a importação dos CSVs originais para tabelas `olist_*_dataset` no PostgreSQL, mantendo os nomes de colunas da base. Para executar **todas** as análises, também é necessária a tabela `olist_sellers_dataset` (base de vendedores), além das tabelas de pedidos, clientes, pagamentos, itens, produtos e avaliações.

## Como executar

1. Baixe os CSVs na página do Kaggle e importe-os para um banco PostgreSQL.
2. Confira os nomes das tabelas e os tipos das colunas, especialmente as datas, que precisam estar como `timestamp` ou `date`.
3. Abra um arquivo `.sql` no DBeaver e execute a consulta desejada (as consultas são independentes).
4. Confira os resultados e registre as conclusões no arquivo `insights.md`.

## Convenções metodológicas

- **Receita de produtos**: `SUM(price)` dos itens, sem frete.
- **Valores pagos**: `SUM(payment_value)` dos registros de pagamento; um pedido pode ter mais de uma linha de pagamento.
- **Recorrência**: uso de `customer_unique_id`, porque `customer_id` identifica o cadastro associado a um pedido.
- **Atraso**: compara a data real de entrega com a data estimada, considerando apenas pedidos efetivamente entregues.
- **Ano de 2017**: usa a data da compra como referência temporal nas análises mensais.
- **Rankings**: `RANK()` pode trazer mais de três linhas por estado em caso de empate na terceira posição.
- **Avaliações por categoria**: a nota de um pedido com itens de categorias diferentes é contabilizada uma vez em cada uma dessas categorias.

> **Importante:** os SQLs foram revisados estaticamente, mas ainda **não foram executados contra o banco de dados**. Os resultados e insights precisam ser validados no DBeaver antes de serem apresentados como descobertas.

## Próximos passos

- Executar e validar as consultas no PostgreSQL.
- Registrar resultados reais e conclusões no `insights.md`.
- Criar gráficos com os achados mais relevantes.
