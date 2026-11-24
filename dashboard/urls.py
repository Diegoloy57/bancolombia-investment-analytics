
from django.urls import path
from . import views

urlpatterns = [
    path("", views.inicio, name="inicio"),

    path(
        "clientes/",
        views.clientes,
        name="clientes"
    ),

    path(
        "clientes-internacionales/",
        views.clientes_internacionales,
        name="clientes_internacionales"
    ),

    path(
        "distribucion-macroactivo/",
        views.distribucion_macroactivo,
        name="distribucion_macroactivo"
    ),

    path(
        "calidad-portafolio/",
        views.calidad_portafolio,
        name="calidad_portafolio"
    ),

    path(
        "segmentacion-clientes/",
        views.segmentacion_clientes,
        name="segmentacion_clientes"
    ),

    path(
        "concentracion-internacional/",
        views.concentracion_internacional,
        name="concentracion_internacional"
    ),

    path(
        "radar/",
        views.radar_clientes,
        name="radar_clientes"
    ),


]
