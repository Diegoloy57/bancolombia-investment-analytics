
import csv
from pathlib import Path

archivos = [
    "historico_aba_macroactivos.csv",
    "historico_aba_usd_internacional.csv",
]

for nombre in archivos:
    ruta = Path("data") / nombre

    with open(ruta, encoding="utf-8-sig", newline="") as archivo:
        filas = list(csv.DictReader(archivo))

    clientes = {
        fila["id_sistema_cliente"]
        for fila in filas
        if fila["id_sistema_cliente"].strip()
    }

    fechas = set()
    for fila in filas:
        anio = fila["ingestion_year"]
        mes = fila["ingestion_month"]
        dia = fila["ingestion_day"]

        if anio and mes and dia:
            fechas.add(
                f"{int(anio):04d}-{int(mes):02d}-{int(dia):02d}"
            )

    print("\nARCHIVO:", nombre)
    print("REGISTROS:", len(filas))
    print("CLIENTES DISTINTOS:", len(clientes))
    print("FECHA MINIMA:", min(fechas) if fechas else "Sin fecha")
    print("FECHA MAXIMA:", max(fechas) if fechas else "Sin fecha")
    print("FECHAS DISTINTAS:", len(fechas))

    print("\nVALORES VACIOS POR COLUMNA:")
    for columna in filas[0]:
        vacios = sum(
            1 for fila in filas
            if not fila[columna].strip()
        )
        print(columna, ":", vacios)

    print("FILAS DUPLICADAS EXACTAS:",
          len(filas) - len({
              tuple(fila.items()) for fila in filas
          }))
