
-- FASE 4: CONTROL DE DUPLICADOS
-- Conservamos RAW sin modificaciones.
-- Agrupamos utilizando todas las columnas originales.

CREATE OR REPLACE VIEW core.vw_macroactivos_duplicados AS

SELECT
    ingestion_year,
    ingestion_month,
    ingestion_day,
    id_sistema_cliente,
    macroactivo,
    cod_activo,
    aba,
    cod_perfil_riesgo,
    cod_banca,
    year,
    month,

    COUNT(*) AS repeticiones,

    CASE
        WHEN COUNT(*) > 1 THEN 'DUPLICADO'
        ELSE 'UNICO'
    END AS estado_duplicado

FROM raw.historico_aba_macroactivos

GROUP BY
    ingestion_year,
    ingestion_month,
    ingestion_day,
    id_sistema_cliente,
    macroactivo,
    cod_activo,
    aba,
    cod_perfil_riesgo,
    cod_banca,
    year,
    month;
