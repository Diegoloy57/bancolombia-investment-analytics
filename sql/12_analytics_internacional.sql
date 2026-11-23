
-- FASE 6: ANALYTICS INTERNACIONAL
-- Portafolio internacional mas reciente por cliente.

CREATE OR REPLACE VIEW analytics.vw_portafolio_internacional_actual AS

WITH ultimas_fechas AS (
    SELECT
        id_sistema_cliente,
        MAX(fecha_ingestion) AS ultima_fecha
    FROM core.vw_internacional
    WHERE estado_fecha = 'VALIDA'
      AND NULLIF(TRIM(id_sistema_cliente), '') IS NOT NULL
    GROUP BY id_sistema_cliente
)

SELECT
    i.id_sistema_cliente,
    i.fecha_ingestion AS fecha_portafolio,
    i.simbol,
    i.cusip,
    i.isin,
    i.nombre_activo,
    i.cantidad_valor AS cantidad,
    i.valor_mercado_num AS valor_mercado,
    i.fecha_vencimiento,
    i.tasa_cupon,
    i.estado_financiero,
    i.repeticiones,

    CASE
        WHEN i.estado_financiero = 'VALIDO'
        THEN TRUE
        ELSE FALSE
    END AS apto_agregacion

FROM core.vw_internacional i

INNER JOIN ultimas_fechas u
    ON i.id_sistema_cliente = u.id_sistema_cliente
   AND i.fecha_ingestion = u.ultima_fecha

WHERE i.numero_copia = 1;
