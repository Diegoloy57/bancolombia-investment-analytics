
import csv
import os
from pathlib import Path

import psycopg
from dotenv import load_dotenv
from psycopg import sql

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")

ARCHIVOS = [
    "cat_perfil_riesgo.csv",
    "catalogo_activos.csv",
    "catalogo_banca.csv",
    "historico_aba_macroactivos.csv",
    "historico_aba_usd_internacional.csv",
]


def cargar_archivo(conexion, nombre):
    ruta = BASE_DIR / "data" / nombre
    tabla = ruta.stem

    with ruta.open(
        "r", encoding="utf-8-sig", newline=""
    ) as archivo:
        lector = csv.reader(archivo)
        columnas = next(lector)

        consulta = sql.SQL(
            "COPY {}.{} ({}) FROM STDIN"
        ).format(
            sql.Identifier("raw"),
            sql.Identifier(tabla),
            sql.SQL(", ").join(
                sql.Identifier(columna) for columna in columnas
            ),
        )

        total = 0

        with conexion.cursor() as cursor:
            with cursor.copy(consulta) as copia:
                for fila in lector:
                    copia.write_row(fila)
                    total += 1

    return total


def main():
    with psycopg.connect(
        host=os.getenv("POSTGRES_HOST", "127.0.0.1"),
        port=os.getenv("POSTGRES_PORT", "5433"),
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
    ) as conexion:

        # Una única transacción para los cinco archivos.
        with conexion.transaction():
            for nombre in ARCHIVOS:
                tabla = Path(nombre).stem

                with conexion.cursor() as cursor:
                    cursor.execute(
                        sql.SQL("TRUNCATE TABLE {}.{}").format(
                            sql.Identifier("raw"),
                            sql.Identifier(tabla),
                        )
                    )

                total = cargar_archivo(conexion, nombre)
                print(f"{tabla}: {total} registros cargados")

    print("\nCarga completada correctamente.")


if __name__ == "__main__":
    main()
