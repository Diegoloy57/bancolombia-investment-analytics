
import os
from pathlib import Path

import psycopg
from dotenv import load_dotenv

from cargar_csv import main as cargar_csv


BASE_DIR = Path(__file__).resolve().parent.parent
CARPETA_SQL = BASE_DIR / "sql"

load_dotenv(BASE_DIR / ".env")


def ejecutar_sql(nombre):
    ruta = CARPETA_SQL / nombre

    print(f"\nEjecutando: {nombre}")

    with psycopg.connect(
        host=os.getenv("POSTGRES_HOST", "127.0.0.1"),
        port=os.getenv("POSTGRES_PORT", "5433"),
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
    ) as conexion:

        with conexion.cursor() as cursor:
            cursor.execute(
                ruta.read_text(encoding="utf-8-sig"),
                prepare=False)

    print("OK")


def main():
    print("INICIALIZACION DEL PROYECTO")

    # 1. Crear tablas y esquemas
    ejecutar_sql("01_create_raw.sql")

    # 2. Cargar los cinco archivos CSV
    print("\nCargando archivos CSV...")
    cargar_csv()

    # 3. Ejecutar validaciones y crear vistas
    archivos = sorted(CARPETA_SQL.glob("*.sql"))

    for archivo in archivos:
        if archivo.name != "01_create_raw.sql":
            ejecutar_sql(archivo.name)

    # 4. Comprobar el modelo analitico
    with psycopg.connect(
        host=os.getenv("POSTGRES_HOST", "127.0.0.1"),
        port=os.getenv("POSTGRES_PORT", "5433"),
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
    ) as conexion:

        with conexion.cursor() as cursor:
            cursor.execute("""
                SELECT COUNT(*)
                FROM analytics.vw_segmentacion_multidimensional
            """)

            total = cursor.fetchone()[0]

    print("\nINICIALIZACION COMPLETADA")
    print(f"Clientes disponibles en el modelo: {total}")


if __name__ == "__main__":
    main()
