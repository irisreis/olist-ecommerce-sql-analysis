# O que os dados da Olist contam sobre vendas, clientes e entregas

Este projeto começou como uma forma de praticar SQL com dados reais de e-commerce, mas, ao longo das consultas, passei a olhar para a base com perguntas que uma equipe de negócios também poderia fazer: onde estão os clientes, quais categorias têm maior peso nas vendas, como os vendedores se distribuem e o que acontece quando uma entrega atrasa?

As análises foram feitas em **PostgreSQL**, usando a base pública **Brazilian E-Commerce Public Dataset by Olist**, disponível no [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). Os scripts estão organizados na pasta [`sql/`](sql/).

> **Como ler os números:** quando falo em *faturamento dos produtos*, estou somando o campo `price` dos itens vendidos, sem frete. Esse valor não deve ser confundido com lucro nem com o total efetivamente recebido pela empresa. Já os valores por forma de pagamento vêm de `payment_value` e representam outra perspectiva da base. Os dados são históricos; as análises não representam o mercado atual.

## 1. Visão geral dos pedidos e clientes

### Situação dos pedidos

A base possui **99.441 pedidos**, dos quais **96.478 foram entregues** (aproximadamente **97%**). Também aparecem **625 cancelados** e **609 indisponíveis**. O volume de entregas concluídas chama a atenção, mas os pedidos não finalizados continuam importantes para investigar eventuais problemas na operação.

### Onde os pedidos se concentram

**São Paulo** lidera em quantidade de pedidos, com **41.746**, seguido por **Rio de Janeiro (12.852)** e **Minas Gerais (11.635)**. Juntos, os três estados representam cerca de **66,6%** dos pedidos da base. Isso mostra uma concentração geográfica bastante forte — sem, por si só, explicar as causas dessa distribuição.

### Faixas de valor dos pedidos

Entre os **98.666 pedidos com itens registrados**, **57.707** ficaram abaixo de **R$ 100**, **37.342** entre **R$ 100 e R$ 500** e **3.617** acima de **R$ 500**. Ou seja, a maior parte dos pedidos analisados está na faixa de menor valor. Aqui, o valor do pedido corresponde à soma dos preços dos produtos, sem frete.

## 2. Vendas e pagamentos

### Como os clientes pagam

O **cartão de crédito** domina os valores registrados em pagamentos, com aproximadamente **R$ 12,54 milhões**, ou **78,34%** do total de **R$ 16,01 milhões**. O boleto vem depois, com **R$ 2,87 milhões** (**17,92%**). Voucher e débito têm participações bem menores.

Vale uma distinção: a média calculada por forma de pagamento é a média **por registro de pagamento**, não necessariamente o ticket médio por pedido, já que um pedido pode ter mais de um registro.

### O comportamento das vendas ao longo de 2017

Em 2017, as consultas de vendas somaram aproximadamente **R$ 7,25 milhões** em produtos. **Novembro** foi o mês de maior faturamento, com **R$ 1,19 milhão** e **7.544 pedidos** na apuração usada. Em relação a outubro, o faturamento cresceu **53,25%**.

É possível que eventos comerciais, como a Black Friday, tenham contribuído para esse pico, mas a consulta sozinha não permite confirmar a causa.

### Vender mais não significa ter um ticket maior

Apesar do pico de faturamento em novembro, o maior ticket médio mensal apareceu em **abril (R$ 173,79)**. Em novembro, ele foi de **R$ 158,39**. Portanto, o destaque de novembro parece estar mais associado ao **volume de pedidos** do que ao aumento do valor médio de cada um.

### Crescimento mês a mês

O maior crescimento percentual ocorreu de **janeiro para fevereiro (+110,78%)**, partindo de uma base relativamente pequena. Já novembro teve um dos movimentos mais relevantes em valor absoluto. Em **dezembro**, houve redução de **26,49%** em relação ao mês anterior.

### Faturamento acumulado e média móvel

A soma acumulada ultrapassou **R$ 5 milhões em outubro** e terminou 2017 em **R$ 7,25 milhões**. O último trimestre concentrou aproximadamente **39,35%** desse total.

A **média móvel dos últimos três meses** chegou a aproximadamente **R$ 950,99 mil em dezembro**. Ela ajuda a observar a tendência com menos influência de oscilações isoladas. Nos dois primeiros meses, a janela usa apenas os meses já disponíveis.

## 3. Clientes e recorrência

### Clientes com maiores valores registrados

Uma das consultas lista os clientes associados aos maiores valores de pagamento. O primeiro registro apresentado soma **R$ 13.664,08**. Esse tipo de ranking é útil para explorar o perfil financeiro da base, mas a interpretação final depende de conferir se o identificador utilizado é `customer_id` ou `customer_unique_id` — diferença importante no conjunto de dados da Olist.

### Quem compra novamente?

Na consulta de recorrência, um mesmo identificador aparece associado a **17 pedidos**, seguido por outros com **9** e **7**. Isso indica que há clientes com múltiplas compras, mas os resultados enviados não permitem calcular com segurança a **taxa geral de recompra**. Para esse indicador, a análise deve consolidar os pedidos por `customer_unique_id`.

### Outras formas de segmentar os clientes

As consultas adicionais sobre clientes ajudam a comparar frequência de compra e valores acumulados. Antes de tirar conclusões mais específicas, ainda preciso validar os nomes das colunas e os critérios dessas consultas, especialmente a terceira coluna de um dos rankings. Preferi deixar essa ressalva explícita em vez de atribuir um significado que não foi confirmado.

## 4. Logística e satisfação

### Atrasos nas entregas

Uma consulta identificou **7.827 pedidos entregues após a data estimada**, aproximadamente **8,11%** das entregas concluídas. Isso sugere que a maioria chegou dentro do prazo estimado, mas existe uma parcela relevante de atrasos a ser investigada.

### Avaliações e pontualidade

A comparação inicial mostrou notas médias de **4,29 para entregas no prazo** e **2,57 para entregas atrasadas** — uma diferença expressiva de **1,72 ponto**.

**Atenção à validação:** o resultado dessa consulta apresentou **276.470** e **23.931** registros nos grupos, totalizando muito mais linhas do que o número de pedidos da base. Isso sugere multiplicação de registros em algum `JOIN`. Por isso, a relação entre atraso e avaliação é uma **hipótese forte a conferir**, e esses números não devem ser apresentados como contagens de pedidos únicos sem corrigir a granularidade da consulta.

### Diferenças entre estados

Entre os **12 estados retornados** pela consulta de taxa de atraso, **Ceará (15,32%)**, **Bahia (14,04%)** e **Rio de Janeiro (13,47%)** apresentaram as maiores proporções. **São Paulo** teve o maior número absoluto de atrasos nessa seleção (**2.387**), mas uma taxa menor (**5,89%**). Esse contraste mostra por que é importante analisar **quantidades e percentuais**, não apenas um deles.

### Tempo médio de entrega

Na análise dos 27 estados, o maior tempo médio observado foi em **Roraima (29,39 dias)**, enquanto **São Paulo apresentou 8,76 dias**. O **Rio de Janeiro ficou em 15,31 dias**. A duração da entrega e a taxa de atraso são indicadores diferentes: uma entrega pode levar muitos dias e, ainda assim, chegar antes da estimativa informada ao cliente.

### Avaliação por categoria

Entre as categorias exibidas, **móveis de escritório** apresentou média de avaliação de **3,62**, enquanto **livros de interesse geral** registrou **4,46**. Esses resultados podem apontar diferenças na experiência de compra, mas é necessário confirmar a contagem das avaliações após os relacionamentos entre pedidos, itens e categorias: uma mesma avaliação pode aparecer mais de uma vez caso o pedido tenha vários itens.

### Quando o frete custa mais do que o produto

Uma das consultas mostrou itens cujo frete superou bastante o valor do próprio produto. No caso mais extremo da amostra, o produto custava **R$ 9,18** e o frete **R$ 54,69** — aproximadamente **595,75%** do preço do item. É um resultado que merece atenção, principalmente em análises de competitividade e experiência de compra. Isso, porém, não demonstra abandono de carrinho: a base contém pedidos realizados, não tentativas de compra abandonadas.

## 5. Produtos, categorias e vendedores

### Categorias com maior faturamento

As três categorias que mais faturaram em produtos foram:

| Categoria | Faturamento dos produtos |
| --- | ---: |
| Beleza e saúde | R$ 1.258.681,34 |
| Relógios e presentes | R$ 1.205.005,68 |
| Cama, mesa e banho | R$ 1.036.988,68 |

A categoria de **cama, mesa e banho** teve mais itens registrados entre essas três (**11.115**), mas não liderou em faturamento. Isso reforça que **volume vendido e valor vendido** contam histórias diferentes.

### Desempenho dos vendedores

O vendedor líder somou **R$ 229.472,63** em produtos, associado a **1.132 pedidos distintos**. O segundo registrou **R$ 222.776,05** em **358 pedidos**, e o terceiro **R$ 200.472,92** em **1.806 pedidos**.

Aqui, a quantidade representa **pedidos distintos**, enquanto o faturamento soma os preços dos itens. Portanto, dividir um pelo outro não gera o mesmo indicador que a média de preço por item.

### Vendedores com itens de maior valor médio

Ao analisar vendedores com **pelo menos 50 pedidos distintos**, o maior valor médio por item encontrado foi **R$ 880,30**, seguido por **R$ 787,20** e **R$ 683,81**. Essa consulta usa `AVG(price)`; o resultado não deve ser chamado de **ticket médio por pedido**.

### Variedade de produtos por vendedor

Entre vendedores com pelo menos **50 pedidos distintos**, há vendedores que comercializam apenas **três produtos distintos** na base, enquanto outros apresentam catálogos maiores. A consulta mede a **variedade do catálogo**, mas, sozinha, não comprova dependência financeira: para isso, seria útil medir quanto cada produto contribui para o faturamento de seu vendedor.

### Vendedores acima da média de faturamento

Outra consulta filtra os vendedores cujo faturamento individual supera a **média de faturamento entre vendedores**. O vendedor mais bem colocado novamente registra **R$ 229.472,63**. O valor do filtro é calculado sobre o faturamento agregado por vendedor, e não sobre a média de preço dos produtos.

### Ranking de vendedores por estado

O ranking estadual revelou líderes como **R$ 229.472,63 em São Paulo**, **R$ 222.776,05 na Bahia** e **R$ 128.111,19 no Rio de Janeiro**. A ideia é comparar vendedores com outros vendedores do **mesmo estado**, sem deixar que os maiores estados dominem todas as posições.

### Quanto cada categoria representa no total?

O faturamento total de produtos considerado nessa consulta foi de **R$ 13.591.643,70**. **Beleza e saúde** respondeu por **9,26%**, seguida de **relógios e presentes (8,87%)** e **cama, mesa e banho (7,63%)**.

As **cinco maiores categorias** concentram aproximadamente **39,74%** desse valor. Também identifiquei **R$ 179.535,28 (1,32%)** em itens cuja categoria aparece sem identificação, um ponto relevante para a qualidade dos dados.

### Diferença de faturamento entre posições do ranking

Comparar cada categoria com a anterior mostrou que a maior distância entre posições consecutivas foi entre **informática e acessórios (R$ 911.954,32)** e **móveis e decoração (R$ 729.762,49)**: **R$ 182.191,83**.

O uso de `LAG()` nessa consulta mede diferenças **entre posições do ranking**, e não perdas ou crescimento ao longo do tempo.

### Participação de cada vendedor em seu estado

Na **Bahia**, o principal vendedor concentra **78,01%** do faturamento dos vendedores do estado na base analisada: **R$ 222.776,05** de **R$ 285.561,56**. Em **Minas Gerais**, o líder representa **10,07%** do total estadual, um cenário bem menos concentrado.

Nos resultados de **Acre, Amazonas e Maranhão**, há apenas um vendedor com vendas registradas, por isso sua participação aparece como **100%**. Isso não significa monopólio no comércio real desses estados. O arquivo exportado para conferência continha os primeiros **200 registros**, então essa comparação não pretende classificar todos os estados do país quanto à concentração.

### As categorias líderes mudam de estado para estado

O ranking nacional não conta toda a história. Em **São Paulo**, a categoria líder foi **cama, mesa e banho (R$ 478.284,52)**; no **Rio de Janeiro**, **relógios e presentes (R$ 185.379,65)**; e em **Minas Gerais**, **beleza e saúde (R$ 157.558,30)**.

**Beleza e saúde liderou em 15 estados**, relógios e presentes em **6**, esporte e lazer em **3**, cama, mesa e banho em **2**, e informática e acessórios em **1**. Essa análise considera o **estado do cliente**, diferentemente das consultas de vendedores, que usam o **estado do vendedor**.

## O que aprendi com o projeto

Mais do que praticar comandos como `JOIN`, `GROUP BY`, `CASE`, CTEs, subconsultas, `RANK()`, `LAG()` e funções de janela, este projeto me fez prestar mais atenção à **pergunta que cada consulta realmente responde**.

Algumas lições ficaram bem claras: faturamento não é lucro; pedido não é a mesma coisa que item; quantidade absoluta pode passar uma impressão diferente da taxa percentual; e um `JOIN` que roda sem erro não significa necessariamente que o resultado esteja correto. A granularidade dos dados faz toda a diferença.

## Limitações e próximos passos

Este é um projeto de aprendizado e ainda há consultas que merecem revisão antes de usar todos os indicadores em um relatório definitivo. As prioridades são:

- Conferir os identificadores e critérios das consultas sobre clientes e recorrência.
- Revisar os `JOIN`s das análises de avaliações para evitar multiplicações indevidas de linhas.
- Confirmar filtros, denominadores e granularidade das métricas de entrega.
- Criar visualizações em Power BI para explorar as diferenças entre estados, categorias e períodos.

A intenção não é apresentar respostas definitivas sobre o e-commerce brasileiro, mas mostrar como transformar consultas SQL em perguntas, descobertas e novas investigações.
