
-- FASE 5: ANALYTICS
-- Portafolio mas reciente por cliente.
-- No modifica los datos originales.

CREATE OR REPLACE VIEW analytics.vw_portafolio_actual_cliente AS

WITH ultimas_fechas AS (
    SELECT
        id_sistema_cliente,
        MAX(fecha_ingestion) AS ultima_fecha
    FROM core.vw_macroactivos_consolidado
    WHERE estado_fecha = 'VALIDA'
      AND NULLIF(TRIM(id_sistema_cliente), '') IS NOT NULL
    GROUP BY id_sistema_cliente
)

SELECT
    m.id_sistema_cliente,
    m.fecha_ingestion AS fecha_portafolio,
    m.macroactivo,
    m.cod_activo,
    m.nombre_activo,
    m.aba_valor,
    m.estado_aba,
    m.estado_activo,
    m.cod_perfil_riesgo,
    m.cod_banca,
    m.repeticiones,

    CASE
        WHEN m.estado_activo = 'REVISAR_ESTRUCTURA'
            THEN 'REVISAR'
        WHEN m.estado_aba <> 'VALIDO'
            THEN 'REVISAR'
        WHEN m.estado_activo IN (
            'NO_CATALOGADO',
            'SIN_CODIGO'
        )
            THEN 'ADVERTENCIA'
        ELSE 'VALIDO'
    END AS estado_posicion,

    CASE
        WHEN m.estado_aba = 'VALIDO'
         AND m.estado_activo IN (
             'CATALOGADO',
             'NO_CATALOGADO',
             'SIN_CODIGO'
         )
            THEN TRUE
        ELSE FALSE
    END AS apto_agregacion

FROM core.vw_macroactivos_consolidado m

INNER JOIN ultimas_fechas u
    ON m.id_sistema_cliente = u.id_sistema_cliente
   AND m.fecha_ingestion = u.ultima_fecha

WHERE m.numero_copia = 1;
