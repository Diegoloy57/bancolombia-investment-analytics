
CREATE OR REPLACE VIEW analytics.vw_caracteristicas_clientes AS

WITH clientes AS (
    SELECT id_sistema_cliente
    FROM analytics.vw_portafolio_actual_cliente

    UNION

    SELECT id_sistema_cliente
    FROM analytics.vw_portafolio_internacional_actual
),

local AS (
    SELECT
        id_sistema_cliente,
        COUNT(*) AS posiciones_locales,
        COUNT(DISTINCT cod_activo) FILTER (
            WHERE cod_activo IS NOT NULL
              AND TRIM(cod_activo) <> ''
        ) AS activos_locales_distintos
    FROM analytics.vw_portafolio_actual_cliente
    GROUP BY id_sistema_cliente
),

internacional AS (
    SELECT
        id_sistema_cliente,
        COUNT(*) AS posiciones_internacionales
    FROM analytics.vw_portafolio_internacional_actual
    GROUP BY id_sistema_cliente
),

concentracion AS (
    SELECT
        id_sistema_cliente,
        COUNT(*) AS tipos_macroactivo,
        ROUND(
            100.0 * MAX(total_aba)
            / NULLIF(SUM(total_aba), 0),
            2
        ) AS concentracion_porcentaje
    FROM analytics.vw_distribucion_macroactivo
    WHERE total_aba > 0
    GROUP BY id_sistema_cliente
)

SELECT
    c.id_sistema_cliente,

    COALESCE(l.posiciones_locales, 0)
        AS posiciones_locales,

    COALESCE(l.activos_locales_distintos, 0)
        AS activos_locales_distintos,

    COALESCE(i.posiciones_internacionales, 0)
        AS posiciones_internacionales,

    COALESCE(co.tipos_macroactivo, 0)
        AS tipos_macroactivo,

    co.concentracion_porcentaje,

    (l.id_sistema_cliente IS NOT NULL)
        AS tiene_local,

    (i.id_sistema_cliente IS NOT NULL)
        AS tiene_internacional,

    CASE
        WHEN c.id_sistema_cliente ~* 'E[+-]?[0-9]+'
            THEN 'NOTACION_CIENTIFICA'
        WHEN LENGTH(TRIM(c.id_sistema_cliente)) < 8
            THEN 'IDENTIFICADOR_CORTO'
        ELSE 'FORMATO_REGULAR'
    END AS estado_identificador

FROM clientes c

LEFT JOIN local l
    ON c.id_sistema_cliente = l.id_sistema_cliente

LEFT JOIN internacional i
    ON c.id_sistema_cliente = i.id_sistema_cliente

LEFT JOIN concentracion co
    ON c.id_sistema_cliente = co.id_sistema_cliente;
