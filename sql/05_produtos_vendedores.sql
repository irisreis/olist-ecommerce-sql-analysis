-- Produtos, categorias e vendedores
-- Projeto: Análise de E-commerce Olist | PostgreSQL
-- As consultas são independentes e podem ser executadas separadamente.

-- ===================================================================
-- Análise 05: Categorias que mais faturam
-- ===================================================================
SELECT
    p.product_category_name AS categoria,
    ROUND(SUM(i.price)::numeric, 2) AS valor_total_produtos,
    COUNT(*) AS quantidade_itens
FROM olist_order_items_dataset AS i
JOIN olist_products_dataset AS p
    ON i.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY valor_total_produtos DESC
LIMIT 10;

-- ===================================================================
-- Análise 08: Desempenho dos vendedores
-- ===================================================================
SELECT
    seller_id AS vendedor_id,
    COUNT(DISTINCT order_id) AS quantidade_pedidos,
    ROUND(SUM(price)::numeric, 2) AS valor_total_produtos
FROM olist_order_items_dataset
GROUP BY seller_id
ORDER BY valor_total_produtos DESC
LIMIT 10;

-- ===================================================================
-- Análise 11: Vendedores com ticket alto
-- ===================================================================
SELECT
    seller_id AS vendedor_id,
    COUNT(DISTINCT order_id) AS quantidade_pedidos,
    ROUND(AVG(price)::numeric, 2) AS valor_medio_item
FROM olist_order_items_dataset
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 50
ORDER BY valor_medio_item DESC;

-- ===================================================================
-- Análise 18: Vendedores com maior dependência de poucos produtos
-- ===================================================================
SELECT
    seller_id AS vendedor_id,
    COUNT(DISTINCT order_id) AS quantidade_pedidos,
    COUNT(DISTINCT product_id) AS produtos_distintos
FROM olist_order_items_dataset
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 50
ORDER BY produtos_distintos ASC, quantidade_pedidos DESC;

-- ===================================================================
-- Análise 21: Vendedores acima da média de faturamento
-- ===================================================================
WITH faturamento_vendedores AS (
    SELECT
        seller_id AS vendedor_id,
        SUM(price) AS faturamento,
        COUNT(DISTINCT order_id) AS quantidade_pedidos
    FROM olist_order_items_dataset
    GROUP BY seller_id
)
SELECT
    vendedor_id,
    ROUND(faturamento::numeric, 2) AS faturamento,
    quantidade_pedidos
FROM faturamento_vendedores
WHERE faturamento > (SELECT AVG(faturamento) FROM faturamento_vendedores)
ORDER BY faturamento DESC;

-- ===================================================================
-- Análise 23: Ranking de vendedores por estado
-- ===================================================================
WITH faturamento_vendedores AS (
    SELECT
        s.seller_state AS estado,
        s.seller_id AS vendedor_id,
        SUM(i.price) AS faturamento
    FROM olist_order_items_dataset AS i
    JOIN olist_sellers_dataset AS s
        ON i.seller_id = s.seller_id
    GROUP BY s.seller_state, s.seller_id
), ranking AS (
    SELECT
        estado,
        vendedor_id,
        faturamento,
        RANK() OVER (
            PARTITION BY estado
            ORDER BY faturamento DESC
        ) AS posicao
    FROM faturamento_vendedores
)
SELECT
    estado,
    vendedor_id,
    ROUND(faturamento::numeric, 2) AS faturamento,
    posicao
FROM ranking
WHERE posicao <= 3
ORDER BY estado, posicao, vendedor_id;

-- ===================================================================
-- Análise 24: Participação de cada categoria no faturamento
-- ===================================================================
WITH faturamento_categorias AS (
    SELECT
        p.product_category_name AS categoria,
        SUM(i.price) AS faturamento
    FROM olist_order_items_dataset AS i
    JOIN olist_products_dataset AS p
        ON i.product_id = p.product_id
    GROUP BY p.product_category_name
)
SELECT
    categoria,
    ROUND(faturamento::numeric, 2) AS faturamento,
    ROUND(SUM(faturamento) OVER ()::numeric, 2) AS faturamento_total,
    ROUND(
        (100.0 * faturamento / NULLIF(SUM(faturamento) OVER (), 0))::numeric,
        2
    ) AS participacao_percentual
FROM faturamento_categorias
ORDER BY faturamento DESC;

-- ===================================================================
-- Análise 25: Comparar cada categoria com a anterior
-- ===================================================================
WITH faturamento_categorias AS (
    SELECT
        p.product_category_name AS categoria,
        SUM(i.price) AS faturamento
    FROM olist_order_items_dataset AS i
    JOIN olist_products_dataset AS p
        ON i.product_id = p.product_id
    GROUP BY p.product_category_name
), comparacao AS (
    SELECT
        categoria,
        faturamento,
        LAG(faturamento) OVER (
            ORDER BY faturamento DESC, categoria
        ) AS faturamento_categoria_anterior
    FROM faturamento_categorias
)
SELECT
    categoria,
    ROUND(faturamento::numeric, 2) AS faturamento,
    ROUND(faturamento_categoria_anterior::numeric, 2) AS faturamento_anterior,
    ROUND((faturamento - faturamento_categoria_anterior)::numeric, 2)
        AS diferenca_reais
FROM comparacao
ORDER BY faturamento DESC, categoria;

-- ===================================================================
-- Análise 26: Participação do vendedor dentro do próprio estado
-- ===================================================================
WITH faturamento_vendedores AS (
    SELECT
        s.seller_state AS estado,
        s.seller_id AS vendedor_id,
        SUM(i.price) AS faturamento
    FROM olist_sellers_dataset AS s
    JOIN olist_order_items_dataset AS i
        ON s.seller_id = i.seller_id
    GROUP BY s.seller_state, s.seller_id
)
SELECT
    estado,
    vendedor_id,
    ROUND(faturamento::numeric, 2) AS faturamento,
    ROUND(SUM(faturamento) OVER (PARTITION BY estado)::numeric, 2)
        AS faturamento_total_estado,
    ROUND(
        (100.0 * faturamento
            / NULLIF(SUM(faturamento) OVER (PARTITION BY estado), 0))::numeric,
        2
    ) AS participacao_percentual
FROM faturamento_vendedores
ORDER BY estado, participacao_percentual DESC;

-- ===================================================================
-- Análise 29: Categoria mais vendida de cada estado
-- ===================================================================
WITH faturamento_categorias_estado AS (
    SELECT
        c.customer_state AS estado,
        p.product_category_name AS categoria,
        SUM(i.price) AS faturamento
    FROM olist_customers_dataset AS c
    JOIN olist_orders_dataset AS o
        ON c.customer_id = o.customer_id
    JOIN olist_order_items_dataset AS i
        ON o.order_id = i.order_id
    JOIN olist_products_dataset AS p
        ON i.product_id = p.product_id
    GROUP BY c.customer_state, p.product_category_name
), ranking AS (
    SELECT
        estado,
        categoria,
        faturamento,
        RANK() OVER (
            PARTITION BY estado
            ORDER BY faturamento DESC
        ) AS posicao
    FROM faturamento_categorias_estado
)
SELECT
    estado,
    categoria,
    ROUND(faturamento::numeric, 2) AS faturamento,
    posicao
FROM ranking
WHERE posicao <= 3
ORDER BY estado, posicao, categoria;
