-- Exploração inicial e segmentação
-- Projeto: Análise de E-commerce Olist | PostgreSQL
-- As consultas são independentes e podem ser executadas separadamente.

-- ===================================================================
-- Análise 01: Visão dos pedidos
-- ===================================================================
SELECT
    order_status AS status_pedido,
    COUNT(*) AS quantidade_pedidos
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY quantidade_pedidos DESC;

-- ===================================================================
-- Análise 03: Pedidos por estado
-- ===================================================================
SELECT
    c.customer_state AS estado,
    COUNT(*) AS quantidade_pedidos
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY quantidade_pedidos DESC;

-- ===================================================================
-- Análise 06: Classificação dos pedidos por valor
-- ===================================================================
WITH valor_por_pedido AS (
    SELECT
        order_id,
        SUM(price) AS valor_produtos
    FROM olist_order_items_dataset
    GROUP BY order_id
), pedidos_classificados AS (
    SELECT
        order_id,
        CASE
            WHEN valor_produtos < 100 THEN 'Baixo valor'
            WHEN valor_produtos <= 500 THEN 'Médio valor'
            ELSE 'Alto valor'
        END AS faixa_valor
    FROM valor_por_pedido
)
SELECT
    faixa_valor,
    COUNT(*) AS quantidade_pedidos
FROM pedidos_classificados
GROUP BY faixa_valor
ORDER BY faixa_valor;
