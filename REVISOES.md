# Revisões feitas em relação ao material original

A autoria e a lógica central dos exercícios foram preservadas, com ajustes de legibilidade e de critérios analíticos:

- **06:** removidos marcadores `**` indevidos e separada a soma por pedido de sua classificação.
- **10, 16 e 19:** adotado `customer_unique_id` para analisar pessoas recorrentes ou gastos por cliente, em vez de `customer_id` (identificador associado a cada pedido).
- **11:** corrigido `> 50` para `>= 50` porque a demanda pede *pelo menos* 50 pedidos.
- **13:** corrigido `> 1000` para `>= 1000`; o filtro de entrega foi explicitado em `WHERE`.
- **14:** convertido o intervalo de timestamps em dias numéricos via segundos / 86400.
- **15:** preservada a lógica de deduplicação por categoria e avaliação; explicitada a interpretação de notas de pedidos multicategoria.
- **17:** proteção contra divisão por zero com `NULLIF`.
- **18:** ordenação corrigida para menor quantidade de produtos distintos primeiro.
- **20:** agregação mensal simplificada e ticket médio calculado sobre pedidos distintos.
- **21:** retirada de agregação repetida por meio de CTE.
- **22:** separada a agregação mensal do cálculo de `LAG`, com proteção contra divisão por zero.
- **23 e 29:** rankings construídos após calcular faturamento; ordenação decrescente no **29**.
- **26:** percentual corrigido para *participação do vendedor*, e não participação dos demais vendedores.
- **27:** padronizada a data de referência (compra) e incluída ordenação final.
- **28:** mantida a janela de três meses, explicitando os nomes de saída.
- **Todas:** palavras-chave em maiúsculas, aliases mais claros, identação e ponto e vírgula.

## Pontos a conferir com a base real

- As consultas usam a convenção de nomes `olist_*_dataset` do material original; confirme sua tabela `olist_sellers_dataset`.
- `RANK()` mantém empates (pode retornar mais de 3 vendedores/categorias por estado).
- O `review_score` é associado ao pedido, não a cada item de forma independente.
- Os conceitos de **faturamento de produtos** e **pagamento recebido** não são equivalentes; este projeto segue as métricas pedidas nos exercícios.
- Nenhuma consulta foi executada neste ambiente, pois o banco PostgreSQL do usuário não está conectado.
