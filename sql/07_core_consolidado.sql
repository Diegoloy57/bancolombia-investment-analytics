
-- FASE 4: CORE CONSOLIDADO
-- Conserva todas las filas e identifica duplicados exactos.

CREATE OR REPLACE VIEW core.vw_macroactivos_consolidado AS

SELECT
    m.*,

    COUNT(*) OVER (
        PARTITION BY
            ingestion_year,
            ingestion_month,
            ingestion_day,
            id_sistema_cliente,
            macroactivo,
            cod_activo,
            aba_original,
            cod_perfil_riesgo,
            cod_banca,
            year,
            month
    ) AS repeticiones,

    ROW_NUMBER() OVER (
        PARTITION BY
            ingestion_year,
            ingestion_month,
            ingestion_day,
            id_sistema_cliente,
            macroactivo,
            cod_activo,
            aba_original,
            cod_perfil_riesgo,
            cod_banca,
            year,
            month
        ORDER BY id_sistema_cliente
    ) AS numero_copia

FROM core.vw_macroactivos_fechas m;
