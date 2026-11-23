
-- FASE 6: ANALYTICS INTERNACIONAL
-- Resumen del portafolio mas reciente por cliente.

CREATE OR REPLACE VIEW analytics.vw_resumen_internacional AS

SELECT
    id_sistema_cliente,

    MAX(fecha_portafolio) AS fecha_portafolio,

    COUNT(*) AS posiciones,

    COUNT(*) FILTER (
        WHERE apto_agregacion
    ) AS posiciones_validas,

    COUNT(*) FILTER (
        WHERE NOT apto_agregacion
    ) AS posiciones_revision,

    SUM(valor_mercado) FILTER (
        WHERE apto_agregacion
    ) AS total_valor_mercado

FROM analytics.vw_portafolio_internacional_actual

GROUP BY id_sistema_cliente;
