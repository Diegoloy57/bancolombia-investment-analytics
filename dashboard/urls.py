from django.urls import path
from . import views

urlpatterns = [
    path("clientes/", views.clientes, name="clientes"),
    path(
        "clientes-internacionales/",
        views.clientes_internacionales,
        name="clientes_internacionales"
    ),
]