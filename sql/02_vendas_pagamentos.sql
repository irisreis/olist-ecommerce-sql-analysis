-- Vendas, pagamentos e evolução temporal
-- Projeto: Análise de E-commerce Olist | PostgreSQL
-- As consultas são independentes e podem ser executadas separadamente.

-- ===================================================================
-- Análise 02: Faturamento por forma de pagamento
-- ===================================================================
SELECT
    payment_type AS tipo_pagamento,
    ROUND(SUM(payment_value)::numeric, 2) AS valor_total_pago,
    ROUND(AVG(payment_value)::numeric, 2) AS valor_medio_pagamento
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY valor_total_pago DESC;

-- ===================================================================
-- Análise 12: Faturamento por mês
-- ===================================================================
SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp)::int AS mes,
    ROUND(SUM(p.payment_value)::numeric, 2) AS total_pago,
    COUNT(DISTINCT o.order_id) AS quantidade_pedidos
FROM olist_orders_dataset AS o
JOIN olist_order_payments_dataset AS p
    ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp >= DATE '2017-01-01'
  AND o.order_purchase_timestamp < DATE '2018-01-01'
GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY mes;

-- ===================================================================
-- Análise 20: Evolução mensal do ticket médio
-- ===================================================================
SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp)::int AS mes,
    ROUND(SUM(p.payment_value)::numeric, 2) AS faturamento_total,
    COUNT(DISTINCT o.order_id) AS quantidade_pedidos,
    ROUND(
        (SUM(p.payment_value) / NULLIF(COUNT(DISTINCT o.order_id), 0))::numeric,
        2
    ) AS ticket_medio_por_pedido
FROM olist_orders_dataset AS o
JOIN olist_order_payments_dataset AS p
    ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp >= DATE '2017-01-01'
  AND o.order_purchase_timestamp < DATE '2018-01-01'
GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY mes;

-- ===================================================================
-- Análise 22: Crescimento mensal do faturamento
-- ===================================================================
WITH faturamento_mensal AS (
    SELECT
        EXTRACT(MONTH FROM o.order_purchase_timestamp)::int AS mes,
        SUM(p.payment_value) AS faturamento
    FROM olist_orders_dataset AS o
    JOIN olist_order_payments_dataset AS p
        ON o.order_id = p.order_id
    WHERE o.order_purchase_timestamp >= DATE '2017-01-01'
      AND o.order_purchase_timestamp < DATE '2018-01-01'
    GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp)
), comparacao AS (
    SELECT
        mes,
        faturamento,
        LAG(faturamento) OVER (ORDER BY mes) AS faturamento_mes_anterior
    FROM faturamento_mensal
)
SELECT
    mes,
    ROUND(faturamento::numeric, 2) AS faturamento,
    ROUND(faturamento_mes_anterior::numeric, 2) AS faturamento_mes_anterior,
    ROUND(
        (100.0 * (faturamento - faturamento_mes_anterior)
            / NULLIF(faturamento_mes_anterior, 0))::numeric,
        2
    ) AS variacao_percentual
FROM comparacao
ORDER BY mes;

-- ===================================================================
-- Análise 27: Faturamento acumulado ao longo de 2017
-- ===================================================================
-- Critério temporal padronizado: data da compra (não data de aprovação).
WITH faturamento_mensal AS (
    SELECT
        EXTRACT(MONTH FROM o.order_purchase_timestamp)::int AS mes,
        SUM(p.payment_value) AS faturamento
    FROM olist_orders_dataset AS o
    JOIN olist_order_payments_dataset AS p
        ON o.order_id = p.order_id
    WHERE o.order_purchase_timestamp >= DATE '2017-01-01'
      AND o.order_purchase_timestamp < DATE '2018-01-01'
    GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp)
)
SELECT
    mes,
    ROUND(faturamento::numeric, 2) AS faturamento,
    ROUND(
        SUM(faturamento) OVER (
            ORDER BY mes ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )::numeric,
        2
    ) AS faturamento_acumulado
FROM faturamento_mensal
ORDER BY mes;

-- ===================================================================
-- Análise 28: Média móvel de faturamento de 3 meses
-- ===================================================================
WITH faturamento_mensal AS (
    SELECT
        EXTRACT(MONTH FROM o.order_purchase_timestamp)::int AS mes,
        SUM(p.payment_value) AS faturamento
    FROM olist_orders_dataset AS o
    JOIN olist_order_payments_dataset AS p
        ON o.order_id = p.order_id
    WHERE o.order_purchase_timestamp >= DATE '2017-01-01'
      AND o.order_purchase_timestamp < DATE '2018-01-01'
    GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp)
)
SELECT
    mes,
    ROUND(faturamento::numeric, 2) AS faturamento,
    ROUND(
        AVG(faturamento) OVER (
            ORDER BY mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::numeric,
        2
    ) AS media_movel_3_meses
FROM faturamento_mensal
ORDER BY mes;
