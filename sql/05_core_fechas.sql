
-- FASE 4: FECHAS EN CORE
-- Agrega fecha de ingestión y estado de calidad.
-- Conserva los registros originales.

CREATE OR REPLACE VIEW core.vw_macroactivos_fechas AS

WITH componentes AS (
    SELECT
        m.*,

        CASE
            WHEN ingestion_year ~ '^[0-9]{4}$'
             AND ingestion_month ~ '^[0-9]{1,2}$'
             AND ingestion_day ~ '^[0-9]{1,2}$'
            THEN ingestion_year::INTEGER
            ELSE NULL
        END AS anio_num,

        CASE
            WHEN ingestion_month ~ '^[0-9]{1,2}$'
            THEN ingestion_month::INTEGER
            ELSE NULL
        END AS mes_num,

        CASE
            WHEN ingestion_day ~ '^[0-9]{1,2}$'
            THEN ingestion_day::INTEGER
            ELSE NULL
        END AS dia_num

    FROM core.vw_macroactivos m
),

validacion AS (
    SELECT
        c.*,

        CASE
            WHEN anio_num BETWEEN 1 AND 9999
             AND mes_num BETWEEN 1 AND 12
             AND dia_num BETWEEN 1 AND 31
            THEN EXTRACT(
                DAY FROM (
                    make_date(anio_num, mes_num, 1)
                    + INTERVAL '1 month - 1 day'
                )
            )::INTEGER
            ELSE NULL
        END AS ultimo_dia_mes

    FROM componentes c
)

SELECT
    v.*,

    CASE
        WHEN ultimo_dia_mes IS NOT NULL
         AND dia_num BETWEEN 1 AND ultimo_dia_mes
        THEN make_date(anio_num, mes_num, dia_num)
        ELSE NULL
    END AS fecha_ingestion,

    CASE
        WHEN ultimo_dia_mes IS NOT NULL
         AND dia_num BETWEEN 1 AND ultimo_dia_mes
        THEN 'VALIDA'
        WHEN ingestion_year IS NULL
          OR TRIM(ingestion_year) = ''
          OR ingestion_month IS NULL
          OR TRIM(ingestion_month) = ''
          OR ingestion_day IS NULL
          OR TRIM(ingestion_day) = ''
        THEN 'INCOMPLETA'
        ELSE 'INVALIDA'
    END AS estado_fecha

FROM validacion v;
