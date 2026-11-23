
-- FASE 5: ANALYTICS
-- Resumen del portafolio mas reciente por cliente.

CREATE OR REPLACE VIEW analytics.vw_resumen_cliente AS

SELECT
    id_sistema_cliente,

    MAX(fecha_portafolio) AS fecha_portafolio,

    COUNT(*) AS posiciones,

    COUNT(*) FILTER (
        WHERE apto_agregacion
    ) AS posiciones_aptas,

    COUNT(*) FILTER (
        WHERE estado_posicion = 'ADVERTENCIA'
    ) AS advertencias,

    COUNT(*) FILTER (
        WHERE estado_posicion = 'REVISAR'
    ) AS posiciones_revision,

    SUM(aba_valor) FILTER (
        WHERE apto_agregacion
    ) AS total_aba

FROM analytics.vw_portafolio_actual_cliente

GROUP BY id_sistema_cliente;
