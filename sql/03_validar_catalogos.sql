
-- Validación de códigos contra catálogos
-- Los registros originales permanecen en RAW.

WITH validacion AS (
    SELECT
        h.cod_perfil_riesgo,
        h.cod_activo,
        h.cod_banca,

        CASE
            WHEN NOT EXISTS (
                SELECT 1
                FROM raw.cat_perfil_riesgo p
                WHERE p.cod_perfil_riesgo = h.cod_perfil_riesgo
            )
            THEN 1 ELSE 0
        END AS error_perfil,

        CASE
            WHEN NOT EXISTS (
                SELECT 1
                FROM raw.catalogo_activos a
                WHERE a.cod_activo = h.cod_activo
            )
            THEN 1 ELSE 0
        END AS error_activo,

        CASE
            WHEN NOT EXISTS (
                SELECT 1
                FROM raw.catalogo_banca b
                WHERE b.cod_banca = h.cod_banca
            )
            THEN 1 ELSE 0
        END AS error_banca

    FROM raw.historico_aba_macroactivos h
)

SELECT
    COUNT(*) AS total_registros,
    SUM(error_perfil) AS errores_perfil,
    SUM(error_activo) AS errores_activo,
    SUM(error_banca) AS errores_banca,
    COUNT(*) FILTER (
        WHERE error_perfil = 1
           OR error_activo = 1
           OR error_banca = 1
    ) AS registros_con_error_catalogo
FROM validacion;


-- Códigos de activos sin correspondencia en el catálogo

SELECT
    h.cod_activo,
    h.macroactivo,
    COUNT(*) AS cantidad_registros

FROM raw.historico_aba_macroactivos h

WHERE NOT EXISTS (
    SELECT 1
    FROM raw.catalogo_activos a
    WHERE a.cod_activo = h.cod_activo
)

GROUP BY
    h.cod_activo,
    h.macroactivo

ORDER BY
    cantidad_registros DESC;
