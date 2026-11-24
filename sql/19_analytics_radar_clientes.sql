
CREATE OR REPLACE VIEW analytics.vw_radar_clientes AS
WITH ultimas_observaciones AS (
    SELECT
        id_sistema_cliente,
        fecha,
        aba_total_cop,
        aba_anterior,
        cantidad_activos,
        variacion_anterior_pct,
        variacion_5_observaciones_pct,
        ROW_NUMBER() OVER (
            PARTITION BY id_sistema_cliente
            ORDER BY fecha DESC
        ) AS numero_fila
    FROM analytics.vw_variables_predictivas
)
SELECT
    id_sistema_cliente,
    fecha AS fecha_ultima_observacion,
    aba_total_cop AS aba_actual_cop,
    cantidad_activos,
    variacion_anterior_pct,
    variacion_5_observaciones_pct,
    CASE
        WHEN variacion_anterior_pct < -1
            THEN 'Seguimiento'
        WHEN variacion_anterior_pct > 1
            THEN 'Oportunidad'
        ELSE 'Estable'
    END AS estado_radar
FROM ultimas_observaciones
WHERE numero_fila = 1
  AND aba_anterior IS NOT NULL;
