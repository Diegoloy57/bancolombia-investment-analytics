
import csv
from collections import Counter
from pathlib import Path

ruta = Path("data/historico_aba_macroactivos.csv")

with open(ruta, encoding="utf-8-sig", newline="") as archivo:
    filas = list(csv.DictReader(archivo))

macroactivos_validos = {
    "Renta Variable",
    "Renta Fija",
    "FICs",
}

errores = Counter()
filas_sospechosas = set()

for numero, fila in enumerate(filas, start=2):
    motivos = []

    if fila["macroactivo"] not in macroactivos_validos:
        motivos.append("macroactivo_invalido")

    if fila["year"] not in ("2023", "2024"):
        motivos.append("year_invalido")

    if fila["month"] not in (
        "1", "2", "3", "4", "5", "11", "12"
    ):
        motivos.append("month_invalido")

    if fila["cod_banca"] not in (
        "PN", "PR", "PF", "PY", "EG"
    ):
        motivos.append("banca_no_reconocida")

    for motivo in motivos:
        errores[motivo] += 1

    if motivos:
        filas_sospechosas.add(numero)

print("TOTAL DE FILAS:", len(filas))
print("FILAS SOSPECHOSAS:", len(filas_sospechosas))

print("\nERRORES DETECTADOS:")
for error, cantidad in errores.items():
    print(error, ":", cantidad)

print("\nNUMEROS DE FILA SOSPECHOSOS:")
print(sorted(filas_sospechosas)[:30])
