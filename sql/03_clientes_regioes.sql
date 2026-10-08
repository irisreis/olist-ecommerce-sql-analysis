-- Clientes e comportamento de compra
-- Projeto: Análise de E-commerce Olist | PostgreSQL
-- As consultas são independentes e podem ser executadas separadamente.

-- ===================================================================
-- Análise 07: Clientes que mais gastaram
-- ===================================================================
SELECT
    o.customer_id AS cliente_id,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_pago,
    COUNT(DISTINCT o.order_id) AS quantidade_pedidos
FROM olist_orders_dataset AS o
JOIN olist_order_payments_dataset AS p
    ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY total_pago DESC
LIMIT 10;

-- ===================================================================
-- Análise 10: Clientes recorrentes
-- ===================================================================
-- Olist diferencia customer_id (identificador por pedido) e customer_unique_id
-- (identificador persistente do cliente). Usamos o segundo para recorrência.
SELECT
    c.customer_unique_id AS cliente_unico_id,
    COUNT(DISTINCT o.order_id) AS quantidade_pedidos
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY quantidade_pedidos DESC;

-- ===================================================================
-- Análise 16: Clientes e formas de pagamento
-- ===================================================================
-- customer_unique_id representa a pessoa ao longo de pedidos diferentes.
SELECT
    c.customer_unique_id AS cliente_unico_id,
    COUNT(DISTINCT o.order_id) AS quantidade_pedidos,
    COUNT(DISTINCT p.payment_type) AS tipos_pagamento_distintos
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset AS p
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) >= 2
ORDER BY quantidade_pedidos DESC;

-- ===================================================================
-- Análise 19: Clientes acima da média de gastos
-- ===================================================================
-- Agrupamento por cliente único, não pelo ID de um pedido específico.
WITH gastos_por_cliente AS (
    SELECT
        c.customer_unique_id AS cliente_unico_id,
        SUM(p.payment_value) AS total_pago
    FROM olist_orders_dataset AS o
    JOIN olist_customers_dataset AS c
        ON o.customer_id = c.customer_id
    JOIN olist_order_payments_dataset AS p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    cliente_unico_id,
    ROUND(total_pago::numeric, 2) AS total_pago
FROM gastos_por_cliente
WHERE total_pago > (SELECT AVG(total_pago) FROM gastos_por_cliente)
ORDER BY total_pago DESC;
