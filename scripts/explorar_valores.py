
import csv
from collections import Counter
from pathlib import Path

archivos = {
    "historico_aba_macroactivos.csv": [
        "macroactivo",
        "cod_activo",
        "cod_perfil_riesgo",
        "cod_banca",
        "year",
        "month",
        "aba",
    ],
    "historico_aba_usd_internacional.csv": [
        "ingestion_year",
        "ingestion_month",
        "ingestion_day",
        "fecha_vencimiento",
        "cantidad",
        "valor_mercado",
        "tasa_cupon",
    ],
}

for nombre, columnas in archivos.items():
    print("\n" + "=" * 60)
    print("ARCHIVO:", nombre)

    with open(
        Path("data") / nombre,
        encoding="utf-8-sig",
        newline=""
    ) as archivo:
        filas = list(csv.DictReader(archivo))

    for columna in columnas:
        valores = [
            fila[columna].strip()
            for fila in filas
            if fila[columna].strip()
        ]

        print("\nCOLUMNA:", columna)
        print("VALORES DISTINTOS:", len(set(valores)))

        if columna in [
            "macroactivo",
            "cod_activo",
            "cod_perfil_riesgo",
            "cod_banca",
            "year",
            "month",
            "ingestion_year",
            "ingestion_month",
            "ingestion_day",
        ]:
            print("FRECUENCIAS:", Counter(valores).most_common(10))
        else:
            print("EJEMPLOS:", list(dict.fromkeys(valores))[:5])
