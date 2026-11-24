
import os
import pandas as pd
import psycopg

from dotenv import load_dotenv
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix

load_dotenv()

conexion = psycopg.connect(
    host=os.getenv("POSTGRES_HOST", "127.0.0.1"),
    port=os.getenv("POSTGRES_PORT", "5433"),
    dbname=os.getenv("POSTGRES_DB"),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD")
)

consulta = """
SELECT
    fecha,
    fecha_siguiente,
    aba_total_cop,
    aba_anterior,
    aba_hace_5_observaciones,
    cantidad_activos,
    variacion_anterior_pct,
    variacion_5_observaciones_pct,
    CASE
        WHEN aba_siguiente > aba_total_cop * 1.01
            THEN 'Oportunidad'
        WHEN aba_siguiente < aba_total_cop * 0.99
            THEN 'Seguimiento'
        ELSE 'Estable'
    END AS comportamiento
FROM analytics.vw_variables_predictivas
WHERE aba_anterior IS NOT NULL
  AND aba_hace_5_observaciones IS NOT NULL
  AND aba_siguiente IS NOT NULL
ORDER BY fecha
"""

with conexion.cursor() as cursor:
    cursor.execute(consulta)
    columnas = [col.name for col in cursor.description]
    datos = cursor.fetchall()

conexion.close()

df = pd.DataFrame(datos, columns=columnas)

df["fecha"] = pd.to_datetime(df["fecha"])
df["fecha_siguiente"] = pd.to_datetime(df["fecha_siguiente"])

variables = [
    "aba_total_cop",
    "aba_anterior",
    "aba_hace_5_observaciones",
    "cantidad_activos",
    "variacion_anterior_pct",
    "variacion_5_observaciones_pct"
]

for columna in variables:
    df[columna] = pd.to_numeric(df[columna])

df = df.dropna(subset=variables)

# Separación cronológica para evitar usar información futura
entrenamiento = df[df["fecha_siguiente"] < "2024-04-01"]
prueba = df[df["fecha"] >= "2024-04-01"]

X_train = entrenamiento[variables]
y_train = entrenamiento["comportamiento"]

X_test = prueba[variables]
y_test = prueba["comportamiento"]

modelo = RandomForestClassifier(
    n_estimators=200,
    max_depth=6,
    min_samples_leaf=10,
    class_weight="balanced",
    random_state=42,
    n_jobs=-1
)

modelo.fit(X_train, y_train)

predicciones = modelo.predict(X_test)

etiquetas = ["Seguimiento", "Estable", "Oportunidad"]

print("\n=== RADAR PREDICTIVO - CLASIFICACION ===")
print("Entrenamiento:", len(entrenamiento))
print("Evaluacion:", len(prueba))

print("\nResultados por categoria:")
print(classification_report(
    y_test,
    predicciones,
    labels=etiquetas,
    zero_division=0
))

print("\nMatriz de confusion:")
matriz = confusion_matrix(
    y_test,
    predicciones,
    labels=etiquetas
)

print(pd.DataFrame(
    matriz,
    index=etiquetas,
    columns=etiquetas
))

print("\nReferencia: predecir siempre Estable")
referencia = ["Estable"] * len(prueba)

print(classification_report(
    y_test,
    referencia,
    labels=etiquetas,
    zero_division=0
))

# Evaluar alertas según la confianza del modelo
probabilidades = modelo.predict_proba(X_test)
clases = modelo.classes_

print("\n=== ALERTAS SEGUN CONFIANZA ===")

for umbral in [0.50, 0.60, 0.70, 0.80]:
    alertas = 0
    aciertos = 0

    for i, prediccion in enumerate(predicciones):
        if prediccion == "Estable":
            continue

        posicion = list(clases).index(prediccion)
        confianza = probabilidades[i][posicion]

        if confianza >= umbral:
            alertas += 1

            if prediccion == y_test.iloc[i]:
                aciertos += 1

    precision = 100 * aciertos / alertas if alertas else 0

    print(
        f"Confianza >= {umbral:.0%}: "
        f"{alertas} alertas, "
        f"{aciertos} aciertos, "
        f"precision {precision:.1f}%"
    )
