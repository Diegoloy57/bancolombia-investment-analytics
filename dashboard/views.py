
from django.http import JsonResponse
from django.db import connection


def clientes(request):
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT
                id_sistema_cliente,
                fecha_portafolio,
                posiciones,
                total_aba
            FROM analytics.vw_resumen_cliente
            ORDER BY id_sistema_cliente
        """)

        columnas = [col[0] for col in cursor.description]
        resultados = [
            dict(zip(columnas, fila))
            for fila in cursor.fetchall()
        ]

    return JsonResponse(
        {"clientes": resultados},
        json_dumps_params={"default": str}
    )

def clientes_internacionales(request):
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT
                id_sistema_cliente,
                fecha_portafolio,
                posiciones,
                posiciones_validas,
                posiciones_revision,
                total_valor_mercado
            FROM analytics.vw_resumen_internacional
            ORDER BY id_sistema_cliente
        """)

        columnas = [col[0] for col in cursor.description]
        resultados = [
            dict(zip(columnas, fila))
            for fila in cursor.fetchall()
        ]

    return JsonResponse(
        {"clientes_internacionales": resultados},
        json_dumps_params={"default": str}
    )
