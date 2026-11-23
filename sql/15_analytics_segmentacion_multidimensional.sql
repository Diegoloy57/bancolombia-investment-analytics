
CREATE OR REPLACE VIEW analytics.vw_segmentacion_multidimensional AS

WITH perfiles AS (
    SELECT
        p.id_sistema_cliente,

        COUNT(DISTINCT p.cod_perfil_riesgo)
            AS codigos_distintos,

        COUNT(*) FILTER (
            WHERE c.cod_perfil_riesgo IS NULL
        ) AS registros_sin_catalogo,

        MAX(c.perfil_riesgo) AS perfil_catalogado

    FROM analytics.vw_portafolio_actual_cliente p

    LEFT JOIN raw.cat_perfil_riesgo c
        ON TRIM(p.cod_perfil_riesgo) =
           TRIM(c.cod_perfil_riesgo)

    GROUP BY p.id_sistema_cliente
)

SELECT
    a.id_sistema_cliente,

    a.posiciones_locales,
    a.activos_locales_distintos,
    a.posiciones_internacionales,
    a.tipos_macroactivo,
    a.concentracion_porcentaje,
    a.tiene_local,
    a.tiene_internacional,
    a.estado_identificador,

    CASE
        WHEN p.id_sistema_cliente IS NULL
            THEN 'SIN_PORTAFOLIO_LOCAL'

        WHEN p.codigos_distintos > 1
            THEN 'PERFIL_INCONSISTENTE'

        WHEN p.registros_sin_catalogo > 0
            THEN 'NO_EN_CATALOGO'

        ELSE p.perfil_catalogado
    END AS perfil_riesgo,

    CASE
        WHEN a.concentracion_porcentaje IS NULL
            THEN 'SIN_CONCENTRACION_CALCULABLE'

        WHEN a.concentracion_porcentaje < 70
            THEN 'DISTRIBUCION_EQUILIBRADA'

        WHEN a.concentracion_porcentaje < 90
            THEN 'CONCENTRACION_MODERADA'

        ELSE 'CONCENTRACION_ELEVADA'
    END AS segmento_concentracion,

    CASE
        WHEN a.posiciones_locales = 0
            THEN 'SIN_INVERSIONES_LOCALES'

        WHEN a.activos_locales_distintos >= 5
            THEN 'VARIEDAD_ALTA'

        WHEN a.activos_locales_distintos >= 2
            THEN 'VARIEDAD_MEDIA'

        WHEN a.activos_locales_distintos = 1
            THEN 'VARIEDAD_BAJA'

        ELSE 'SIN_CODIGOS_VALIDOS'
    END AS segmento_variedad,

    CASE
        WHEN a.tiene_local AND a.tiene_internacional
            THEN 'AMBOS_MERCADOS'

        WHEN a.tiene_local
            THEN 'SOLO_LOCAL'

        ELSE 'SOLO_INTERNACIONAL'
    END AS segmento_mercado

FROM analytics.vw_caracteristicas_clientes a

LEFT JOIN perfiles p
    ON a.id_sistema_cliente = p.id_sistema_cliente;
