
import csv
from pathlib import Path

carpeta = Path("data")

archivos = [
    "cat_perfil_riesgo.csv",
    "catalogo_activos.csv",
    "catalogo_banca.csv",
    "historico_aba_macroactivos.csv",
    "historico_aba_usd_internacional.csv",
]

for nombre in archivos:
    ruta = carpeta / nombre

    print("\n" + "=" * 60)
    print("ARCHIVO:", nombre)

    with open(ruta, "r", encoding="utf-8-sig", newline="") as archivo:
        muestra = archivo.read(8192)
        archivo.seek(0)

        separador = csv.Sniffer().sniff(
            muestra, delimiters=",;\t|"
        ).delimiter

        lector = csv.DictReader(archivo, delimiter=separador)

        print("SEPARADOR:", repr(separador))
        print("COLUMNAS:", lector.fieldnames)

        total = 0
        ejemplos = []

        for fila in lector:
            total += 1

            if len(ejemplos) < 2:
                ejemplos.append(fila)

        print("TOTAL DE REGISTROS:", total)
        print("PRIMERAS DOS FILAS:")

        for ejemplo in ejemplos:
            print(ejemplo)

print("\nAUDITORÍA FINALIZADA")
