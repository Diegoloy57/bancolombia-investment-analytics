
CREATE OR REPLACE VIEW analytics.vw_concentracion_internacional AS

WITH posiciones AS (
    SELECT
        id_sistema_cliente,
        COALESCE(
            NULLIF(TRIM(isin), ''),
            NULLIF(TRIM(simbol), ''),
            nombre_activo
        ) AS identificador,
        MAX(nombre_activo) AS nombre_activo,
        SUM(valor_mercado) AS valor_usd
    FROM analytics.vw_portafolio_internacional_actual
    WHERE apto_agregacion = TRUE
      AND valor_mercado > 0
    GROUP BY
        id_sistema_cliente,
        COALESCE(
            NULLIF(TRIM(isin), ''),
            NULLIF(TRIM(simbol), ''),
            nombre_activo
        )
),

ranking AS (
    SELECT
        *,
        SUM(valor_usd) OVER (
            PARTITION BY id_sistema_cliente
        ) AS total_cliente_usd,
        COUNT(*) OVER (
            PARTITION BY id_sistema_cliente
        ) AS activos_distintos,
        ROW_NUMBER() OVER (
            PARTITION BY id_sistema_cliente
            ORDER BY valor_usd DESC, identificador
        ) AS posicion
    FROM posiciones
)

SELECT
    id_sistema_cliente,
    activos_distintos,
    identificador AS activo_principal,
    nombre_activo,
    ROUND(total_cliente_usd::numeric, 2) AS total_usd,
    ROUND(valor_usd::numeric, 2) AS valor_principal_usd,
    ROUND(
        (100.0 * valor_usd / NULLIF(total_cliente_usd, 0))::numeric,
        2
    ) AS concentracion_porcentaje,
    CASE
        WHEN valor_usd / NULLIF(total_cliente_usd, 0) >= 0.90
            THEN 'REVISION_PRIORITARIA'
        WHEN valor_usd / NULLIF(total_cliente_usd, 0) >= 0.50
            THEN 'SEGUIMIENTO'
        ELSE 'CONCENTRACION_MENOR'
    END AS clasificacion
FROM ranking
WHERE posicion = 1;
