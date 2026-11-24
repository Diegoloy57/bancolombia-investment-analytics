
CREATE OR REPLACE VIEW analytics.vw_variables_predictivas AS

WITH clientes_aptos AS (
    SELECT id_sistema_cliente
    FROM analytics.vw_aba_diario_predictivo
    GROUP BY id_sistema_cliente
    HAVING COUNT(*) >= 30
),

historial AS (
    SELECT
        a.id_sistema_cliente,
        a.fecha,
        a.aba_total_cop,
        a.cantidad_activos,

        LAG(a.aba_total_cop, 1) OVER (
            PARTITION BY a.id_sistema_cliente
            ORDER BY a.fecha
        ) AS aba_anterior,

        LAG(a.aba_total_cop, 5) OVER (
            PARTITION BY a.id_sistema_cliente
            ORDER BY a.fecha
        ) AS aba_hace_5_observaciones,

        LEAD(a.aba_total_cop, 1) OVER (
            PARTITION BY a.id_sistema_cliente
            ORDER BY a.fecha
        ) AS aba_siguiente,

        LEAD(a.fecha, 1) OVER (
            PARTITION BY a.id_sistema_cliente
            ORDER BY a.fecha
        ) AS fecha_siguiente

    FROM analytics.vw_aba_diario_predictivo a
    INNER JOIN clientes_aptos c
        ON a.id_sistema_cliente = c.id_sistema_cliente
)

SELECT
    id_sistema_cliente,
    fecha,
    aba_total_cop,
    cantidad_activos,
    aba_anterior,
    aba_hace_5_observaciones,
    aba_siguiente,
    fecha_siguiente,

    ROUND(
        100.0 * (aba_total_cop - aba_anterior)
        / NULLIF(aba_anterior, 0),
        4
    ) AS variacion_anterior_pct,

    ROUND(
        100.0 * (aba_total_cop - aba_hace_5_observaciones)
        / NULLIF(aba_hace_5_observaciones, 0),
        4
    ) AS variacion_5_observaciones_pct

FROM historial;
