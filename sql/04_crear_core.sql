
-- FASE 4: CAPA CORE
-- Vista de macroactivos con valores tipados
-- y clasificación de calidad de los códigos.

CREATE OR REPLACE VIEW core.vw_macroactivos AS

SELECT
    h.ingestion_year,
    h.ingestion_month,
    h.ingestion_day,
    h.id_sistema_cliente,
    h.macroactivo,
    h.cod_activo,

    -- Descripción del catálogo
    a.activo AS nombre_activo,

    -- Valor original
    h.aba AS aba_original,

    -- Conversión segura a número
    CASE
        WHEN TRIM(h.aba) ~ '^[+-]?[0-9]+([.][0-9]+)?$'
        THEN TRIM(h.aba)::NUMERIC
        ELSE NULL
    END AS aba_valor,

    -- Calidad del valor financiero
    CASE
        WHEN h.aba IS NULL
          OR LOWER(TRIM(h.aba)) IN ('', 'none', 'null')
        THEN 'SIN_VALOR'
        WHEN TRIM(h.aba) ~ '^[+-]?[0-9]+([.][0-9]+)?$'
        THEN 'VALIDO'
        ELSE 'FORMATO_INVALIDO'
    END AS estado_aba,

    -- Calidad del código del activo
    CASE
        WHEN h.cod_activo IS NULL
          OR LOWER(TRIM(h.cod_activo)) IN ('', 'none', 'null')
        THEN 'SIN_CODIGO'
        WHEN TRIM(h.cod_activo) !~ '^[0-9]+$'
        THEN 'REVISAR_ESTRUCTURA'
        WHEN a.cod_activo IS NULL
        THEN 'NO_CATALOGADO'
        ELSE 'CATALOGADO'
    END AS estado_activo,

    h.cod_perfil_riesgo,
    h.cod_banca,
    h.year,
    h.month

FROM raw.historico_aba_macroactivos h

LEFT JOIN (
    SELECT DISTINCT ON (cod_activo)
        cod_activo,
        activo
    FROM raw.catalogo_activos
    ORDER BY cod_activo, activo
) a
    ON h.cod_activo = a.cod_activo;
