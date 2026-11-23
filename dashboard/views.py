
from django.http import JsonResponse
from django.db import connection
from django.shortcuts import render


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

def inicio(request):
    cliente_seleccionado = request.GET.get("cliente", "")

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT id_sistema_cliente
            FROM analytics.vw_resumen_cliente

            UNION

            SELECT id_sistema_cliente
            FROM analytics.vw_resumen_internacional

            ORDER BY id_sistema_cliente
        """)

        clientes = [fila[0] for fila in cursor.fetchall()]

        cursor.execute("""
            SELECT
                fecha_portafolio,
                posiciones,
                total_aba
            FROM analytics.vw_resumen_cliente
            WHERE id_sistema_cliente = %s
        """, [cliente_seleccionado])

        local = cursor.fetchone()

        cursor.execute("""
            SELECT
                fecha_portafolio,
                posiciones,
                posiciones_validas,
                posiciones_revision,
                total_valor_mercado
            FROM analytics.vw_resumen_internacional
            WHERE id_sistema_cliente = %s
        """, [cliente_seleccionado])

        internacional = cursor.fetchone()

    return render(request, "dashboard/inicio.html", {
        "clientes": clientes,
        "cliente_seleccionado": cliente_seleccionado,
        "local": local,
        "internacional": internacional,
    })


def distribucion_macroactivo(request):
    cliente = request.GET.get("cliente", "")

    if not cliente:
        return JsonResponse({
            "error": "Debe seleccionar un cliente."
        }, status=400)

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT
                macroactivo,
                cantidad_posiciones,
                total_aba
            FROM analytics.vw_distribucion_macroactivo
            WHERE id_sistema_cliente = %s
            ORDER BY macroactivo
        """, [cliente])

        resultados = [
            {
                "macroactivo": fila[0],
                "cantidad_posiciones": fila[1],
                "total_aba": (
                    float(fila[2])
                    if fila[2] is not None
                    else None
                )
            }
            for fila in cursor.fetchall()
        ]

    return JsonResponse({
        "cliente": cliente,
        "distribucion": resultados
    })

def calidad_portafolio(request):
    cliente = request.GET.get("cliente", "")

    if not cliente:
        return JsonResponse({
            "error": "Debe seleccionar un cliente."
        }, status=400)

    with connection.cursor() as cursor:

        # Calidad del portafolio local
        cursor.execute("""
            SELECT
                estado_aba,
                estado_activo,
                COUNT(*) AS posiciones
            FROM analytics.vw_portafolio_actual_cliente
            WHERE id_sistema_cliente = %s
            GROUP BY estado_aba, estado_activo
            ORDER BY estado_aba, estado_activo
        """, [cliente])

        local = [
            {
                "estado_aba": fila[0],
                "estado_activo": fila[1],
                "posiciones": fila[2]
            }
            for fila in cursor.fetchall()
        ]

        # Calidad del portafolio internacional
        cursor.execute("""
            SELECT
                estado_financiero,
                apto_agregacion,
                COUNT(*) AS posiciones
            FROM analytics.vw_portafolio_internacional_actual
            WHERE id_sistema_cliente = %s
            GROUP BY estado_financiero, apto_agregacion
            ORDER BY estado_financiero, apto_agregacion
        """, [cliente])

        internacional = [
            {
                "estado_financiero": fila[0],
                "apto_agregacion": fila[1],
                "posiciones": fila[2]
            }
            for fila in cursor.fetchall()
        ]

    return JsonResponse({
        "cliente": cliente,
        "calidad_local": local,
        "calidad_internacional": internacional
    })

def segmentacion_clientes(request):
    from django.db import connection
    from django.http import JsonResponse

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT
                id_sistema_cliente,
                perfil_riesgo,
                segmento_concentracion,
                segmento_variedad,
                segmento_mercado,
                concentracion_porcentaje,
                posiciones_locales,
                posiciones_internacionales,
                estado_identificador
            FROM analytics.vw_segmentacion_multidimensional
            ORDER BY id_sistema_cliente
        """)

        columnas = [col[0] for col in cursor.description]
        clientes = [
            dict(zip(columnas, fila))
            for fila in cursor.fetchall()
        ]

    return JsonResponse({
        "total_clientes": len(clientes),
        "clientes": clientes
    })

def concentracion_internacional(request):
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT
                id_sistema_cliente,
                activos_distintos,
                activo_principal,
                nombre_activo,
                total_usd,
                valor_principal_usd,
                concentracion_porcentaje,
                clasificacion
            FROM analytics.vw_concentracion_internacional
            ORDER BY concentracion_porcentaje DESC
        """)

        columnas = [col[0] for col in cursor.description]
        clientes = [
            dict(zip(columnas, fila))
            for fila in cursor.fetchall()
        ]

    return JsonResponse({
        "total_clientes": len(clientes),
        "clientes": clientes
    }, json_dumps_params={"default": str})

