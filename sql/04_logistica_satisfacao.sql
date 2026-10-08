-- Logística, frete e avaliações
-- Projeto: Análise de E-commerce Olist | PostgreSQL
-- As consultas são independentes e podem ser executadas separadamente.

-- ===================================================================
-- Análise 04: Atrasos nas entregas
-- ===================================================================
SELECT
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date > order_estimated_delivery_date
    ) AS pedidos_atrasados,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_delivered_customer_date > order_estimated_delivery_date
        ) / NULLIF(COUNT(*) FILTER (
            WHERE order_delivered_customer_date IS NOT NULL
        ), 0),
        2
    ) AS percentual_atrasados
FROM olist_orders_dataset;

-- ===================================================================
-- Análise 09: Avaliação × atraso
-- ===================================================================
SELECT
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Com atraso'
        ELSE 'No prazo'
    END AS situacao_entrega,
    ROUND(AVG(r.review_score)::numeric, 2) AS nota_media,
    COUNT(*) AS quantidade_avaliacoes
FROM olist_orders_dataset AS o
JOIN olist_order_reviews_dataset AS r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY situacao_entrega
ORDER BY nota_media DESC;

-- ===================================================================
-- Análise 13: Estados com problema de atraso
-- ===================================================================
SELECT
    c.customer_state AS estado,
    COUNT(*) AS pedidos_entregues,
    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) AS pedidos_atrasados,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS percentual_atrasados
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 1000
ORDER BY percentual_atrasados DESC;

-- ===================================================================
-- Análise 14: Tempo médio de entrega por estado
-- ===================================================================
SELECT
    c.customer_state AS estado,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (
            o.order_delivered_customer_date - o.order_purchase_timestamp
        )) / 86400)::numeric,
        2
    ) AS media_dias_entrega
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY media_dias_entrega DESC;

-- ===================================================================
-- Análise 15: Categorias com avaliações ruins
-- ===================================================================
-- Cada avaliação se refere a um pedido, que pode conter várias categorias.
-- Uma avaliação conta uma vez em cada categoria presente naquele pedido.
WITH categorias_por_pedido AS (
    SELECT DISTINCT
        i.order_id,
        p.product_category_name AS categoria
    FROM olist_order_items_dataset AS i
    JOIN olist_products_dataset AS p
        ON i.product_id = p.product_id
), avaliacoes_por_categoria AS (
    SELECT DISTINCT
        cp.categoria,
        r.review_id,
        r.review_score
    FROM categorias_por_pedido AS cp
    JOIN olist_order_reviews_dataset AS r
        ON cp.order_id = r.order_id
)
SELECT
    categoria,
    ROUND(AVG(review_score)::numeric, 2) AS nota_media,
    COUNT(DISTINCT review_id) AS quantidade_avaliacoes
FROM avaliacoes_por_categoria
GROUP BY categoria
HAVING COUNT(DISTINCT review_id) >= 100
ORDER BY nota_media ASC;

-- ===================================================================
-- Análise 17: Impacto do frete no valor da compra
-- ===================================================================
SELECT
    order_id AS pedido_id,
    ROUND(SUM(price)::numeric, 2) AS valor_produtos,
    ROUND(SUM(freight_value)::numeric, 2) AS valor_frete,
    ROUND(
        (100.0 * SUM(freight_value) / NULLIF(SUM(price), 0))::numeric,
        2
    ) AS percentual_frete_sobre_produtos
FROM olist_order_items_dataset
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY percentual_frete_sobre_produtos DESC NULLS LAST;
