
-- FASE 3: VALIDACIÓN DE CALIDAD DE DATOS
-- Identificación de registros sospechosos en macroactivos.

WITH validacion AS (
    SELECT
        id_sistema_cliente,
        macroactivo,
        cod_activo,
        aba,
        cod_perfil_riesgo,
        cod_banca,
        year,
        month,

        CASE
            WHEN macroactivo NOT IN (
                'Renta Variable',
                'Renta Fija',
                'FICs'
            )
            OR macroactivo IS NULL
            THEN 1 ELSE 0
        END AS error_macroactivo,

        CASE
            WHEN cod_banca NOT IN (
                'PN', 'PR', 'PF', 'PY', 'EG'
            )
            OR cod_banca IS NULL
            THEN 1 ELSE 0
        END AS error_banca,

        CASE
            WHEN year NOT IN ('2023', '2024')
            OR year IS NULL
            THEN 1 ELSE 0
        END AS error_year,

        CASE
            WHEN month NOT IN (
                '1', '2', '3', '4', '5', '11', '12'
            )
            OR month IS NULL
            THEN 1 ELSE 0
        END AS error_month

    FROM raw.historico_aba_macroactivos
)

SELECT
    COUNT(*) AS total_registros,

    SUM(error_macroactivo) AS errores_macroactivo,
    SUM(error_banca) AS errores_banca,
    SUM(error_year) AS errores_year,
    SUM(error_month) AS errores_month,

    COUNT(*) FILTER (
        WHERE error_macroactivo = 1
           OR error_banca = 1
           OR error_year = 1
           OR error_month = 1
    ) AS registros_sospechosos

FROM validacion;
