
-- FASE 6: CORE INTERNACIONAL
-- Limpieza, fechas y duplicados.
-- Conserva los registros RAW.

CREATE OR REPLACE VIEW core.vw_internacional AS

WITH base AS (
    SELECT
        r.*,

        CASE
            WHEN TRIM(cantidad) ~ '^[+-]?[0-9]+([.][0-9]+)?$'
            THEN TRIM(cantidad)::NUMERIC
            ELSE NULL
        END AS cantidad_valor,

        CASE
            WHEN TRIM(valor_mercado) ~ '^[+-]?[0-9]+([.][0-9]+)?$'
            THEN TRIM(valor_mercado)::NUMERIC
            ELSE NULL
        END AS valor_mercado_num,

        CASE
            WHEN ingestion_year ~ '^[0-9]{4}$'
             AND ingestion_month ~ '^[0-9]{1,2}$'
             AND ingestion_day ~ '^[0-9]{1,2}$'
             AND ingestion_month::INTEGER BETWEEN 1 AND 12
             AND ingestion_day::INTEGER BETWEEN 1 AND 31
            THEN MAKE_DATE(
                ingestion_year::INTEGER,
                ingestion_month::INTEGER,
                1
            ) + (ingestion_day::INTEGER - 1)
            ELSE NULL
        END AS fecha_ingestion,

        COUNT(*) OVER (
            PARTITION BY
                ingestion_year,
                ingestion_month,
                ingestion_day,
                id_sistema_cliente,
                simbol,
                cusip,
                isin,
                nombre_activo,
                cantidad,
                valor_mercado,
                fecha_vencimiento,
                tasa_cupon
        ) AS repeticiones,

        ROW_NUMBER() OVER (
            PARTITION BY
                ingestion_year,
                ingestion_month,
                ingestion_day,
                id_sistema_cliente,
                simbol,
                cusip,
                isin,
                nombre_activo,
                cantidad,
                valor_mercado,
                fecha_vencimiento,
                tasa_cupon
            ORDER BY id_sistema_cliente
        ) AS numero_copia

    FROM raw.historico_aba_usd_internacional r
)

SELECT
    *,

    CASE
        WHEN cantidad_valor IS NOT NULL
         AND valor_mercado_num IS NOT NULL
        THEN 'VALIDO'
        ELSE 'REVISAR'
    END AS estado_financiero,

    CASE
        WHEN fecha_ingestion IS NOT NULL
        THEN 'VALIDA'
        ELSE 'INVALIDA'
    END AS estado_fecha

FROM base;
