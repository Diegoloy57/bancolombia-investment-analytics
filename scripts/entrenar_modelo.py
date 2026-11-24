
import os
import pandas as pd
import psycopg

from dotenv import load_dotenv
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error

load_dotenv()

# 1. Conectar con PostgreSQL
conexion = psycopg.connect(
    host=os.getenv("POSTGRES_HOST", "127.0.0.1"),
    port=os.getenv("POSTGRES_PORT", "5433"),
    dbname=os.getenv("POSTGRES_DB"),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD")
)

# 2. Consultar las variables preparadas en SQL
consulta = """
SELECT
    id_sistema_cliente,
    fecha,
    fecha_siguiente,
    aba_total_cop,
    aba_anterior,
    aba_hace_5_observaciones,
    cantidad_activos,
    variacion_anterior_pct,
    variacion_5_observaciones_pct,
    aba_siguiente
FROM analytics.vw_variables_predictivas
WHERE aba_anterior IS NOT NULL
  AND aba_hace_5_observaciones IS NOT NULL
  AND aba_siguiente IS NOT NULL
ORDER BY fecha, id_sistema_cliente
"""

with conexion.cursor() as cursor:
    cursor.execute(consulta)
    columnas = [col.name for col in cursor.description]
    datos = cursor.fetchall()

conexion.close()

df = pd.DataFrame(datos, columns=columnas)

# 3. Preparar los tipos de datos
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

for columna in variables + ["aba_siguiente"]:
    df[columna] = pd.to_numeric(df[columna])

df = df.dropna(subset=variables + ["aba_siguiente"])

# 4. Separar cronológicamente
# Entrenar hasta marzo y evaluar desde abril.
entrenamiento = df[df["fecha_siguiente"] < "2024-04-01"]
prueba = df[df["fecha"] >= "2024-04-01"]

X_train = entrenamiento[variables]
y_train = (
    entrenamiento["aba_siguiente"]
    / entrenamiento["aba_total_cop"] - 1
)
y_train = y_train.clip(-0.50,0.50)

X_test = prueba[variables]
y_test = prueba["aba_siguiente"]

# 5. Entrenar la regresión
modelo = RandomForestRegressor(
    n_estimators=100,
    max_depth=5,
    min_samples_leaf=10,
    random_state=42,
    n_jobs=-1,
)

modelo.fit(X_train, y_train)

# 6. Predecir el ABA futuro
cambio_estimado = modelo.predict(X_test)

cambio_estimado = cambio_estimado.clip (-0.50,0.50)

predicciones = (
    prueba ["aba_total_cop"].to_numpy()
    *(1 + cambio_estimado)) 

# 7. Comparar contra una predicción básica
prediccion_basica = prueba["aba_total_cop"]

error_modelo = mean_absolute_error(y_test, predicciones)
error_basico = mean_absolute_error(y_test, prediccion_basica)

print("\n=== RADAR PREDICTIVO DE CLIENTES ===")
print("Clientes:", df["id_sistema_cliente"].nunique())
print("Ejemplos de entrenamiento:", len(entrenamiento))
print("Ejemplos de evaluación:", len(prueba))
print(f"Error promedio del modelo: ${error_modelo:,.2f} COP")
print(f"Error promedio de referencia: ${error_basico:,.2f} COP")

if error_modelo < error_basico:
    print("Resultado: el modelo supera la referencia básica.")
else:
    print("Resultado: la referencia básica funciona mejor.")

print("\nPrimeras 5 predicciones:")
resultado = prueba[
    ["id_sistema_cliente", "fecha", "aba_total_cop", "aba_siguiente"]
].head(5).copy()

resultado["aba_estimado"] = predicciones[:5]

print(resultado.to_string(index=False))
