
-- FASE 5: ANALYTICS
-- Distribucion del portafolio por macroactivo.

CREATE OR REPLACE VIEW analytics.vw_distribucion_macroactivo AS

SELECT
    id_sistema_cliente,
    fecha_portafolio,
    macroactivo,

    COUNT(*) AS cantidad_posiciones,

    SUM(aba_valor) AS total_aba

FROM analytics.vw_portafolio_actual_cliente

WHERE apto_agregacion = TRUE

GROUP BY
    id_sistema_cliente,
    fecha_portafolio,
    macroactivo;
