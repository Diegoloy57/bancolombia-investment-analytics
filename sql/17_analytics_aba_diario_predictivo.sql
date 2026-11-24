
CREATE OR REPLACE VIEW analytics.vw_aba_diario_predictivo AS

WITH datos_validos AS (
    SELECT
        id_sistema_cliente,
        macroactivo,
        cod_activo,
        make_date(
            ingestion_year::integer,
            ingestion_month::integer,
            ingestion_day::integer
        ) AS fecha,
        CASE
          WHEN TRIM (aba) ~ '^-?[0-9]+([.,][0-9]+)?$'
          THEN REPLACE(TRIM(aba), ',', '.')::numeric
          ELSE NULL
        END AS aba
    FROM raw.historico_aba_macroactivos
    WHERE ingestion_year ~ '^[0-9]{4}$'
      AND ingestion_month ~ '^[0-9]{1,2}$'
      AND ingestion_day ~ '^[0-9]{1,2}$'
      AND ingestion_year::integer BETWEEN 2023 AND 2024
      AND ingestion_month::integer BETWEEN 1 AND 12
      AND ingestion_day::integer BETWEEN 1 AND 31
      
      AND ingestion_day::integer <= EXTRACT(
          DAY FROM (
              make_date(
                  ingestion_year::integer,
                  ingestion_month::integer,
                  1
              ) + INTERVAL '1 month - 1 day'
          )
      )
),

posiciones AS (

    SELECT
        id_sistema_cliente,
        fecha,
        macroactivo,
        cod_activo,
        MIN(aba) AS aba_posicion,
        COUNT(DISTINCT aba) AS valores_distintos
    FROM datos_validos
    GROUP BY
        id_sistema_cliente,
        fecha,
        macroactivo,
        cod_activo
),

fechas_incompletas AS (
    SELECT DISTINCT
        id_sistema_cliente,
        make_date(
            ingestion_year::integer,
            ingestion_month::integer,
            ingestion_day::integer
        ) AS fecha
    FROM raw.historico_aba_macroactivos
    WHERE (
        (id_sistema_cliente = '10038643094'
         AND ingestion_year = '2023'
         AND ingestion_month = '11'
         AND ingestion_day = '23')
        OR
        (id_sistema_cliente = '1.0089E+11'
         AND ingestion_year = '2023'
         AND ingestion_month = '12'
         AND ingestion_day = '19')
        OR
        (id_sistema_cliente = '10032184607'
         AND ingestion_year = '2024'
         AND ingestion_month = '1'
         AND ingestion_day = '2')
        OR
        (id_sistema_cliente = '10039553126'
         AND ingestion_year = '2024'
         AND ingestion_month = '2'
         AND ingestion_day = '14')
        OR
        (id_sistema_cliente = '10041560001'
         AND ingestion_year = '2024'
         AND ingestion_month = '3'
         AND ingestion_day = '11')
    )
),
aba_diario AS (
    SELECT
        id_sistema_cliente,
        fecha,
        SUM(aba_posicion) AS aba_total_cop,
        COUNT(*) AS cantidad_activos,
        SUM(
            CASE WHEN valores_distintos > 1
                 THEN 1 ELSE 0 END
        ) AS posiciones_conflictivas
    FROM posiciones
    GROUP BY id_sistema_cliente, fecha
)

SELECT
    id_sistema_cliente,
    fecha,
    ROUND(aba_total_cop, 2) AS aba_total_cop,
    cantidad_activos

FROM aba_diario a
WHERE a.posiciones_conflictivas = 0
  AND NOT EXISTS (
      SELECT 1
      FROM fechas_incompletas f
      WHERE f.id_sistema_cliente = a.id_sistema_cliente
        AND f.fecha = a.fecha
  );

