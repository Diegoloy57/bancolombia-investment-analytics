
# Bancolombia Investment Analytics

## Prueba técnica — Analítica de Inversiones

Proyecto de análisis de portafolios de inversión desarrollado para una prueba técnica relacionada con la Vicepresidencia de Estructuración de Mercado de Capitales.

El sistema permite consultar, consolidar y analizar posiciones de inversión locales (COP) e internacionales (USD), utilizando PostgreSQL, Python, Django y herramientas de visualización web.

> Proyecto académico de evaluación técnica. No es una herramienta oficial de Bancolombia ni genera recomendaciones personalizadas de inversión.

## 1. Objetivo

Construir una solución reproducible que permita:

- Cargar información financiera desde archivos CSV.
- Validar la calidad de los datos.
- Transformar y consolidar información mediante SQL.
- Consultar portafolios de inversión por cliente.
- Visualizar indicadores mediante un dashboard.
- Identificar concentraciones y características de los portafolios.
- Generar información útil para el análisis financiero y comercial.

## 2. Tecnologías utilizadas

- Python
- PostgreSQL 17
- Django 5
- Docker y Docker Compose
- SQL
- HTML, CSS y JavaScript
- Bootstrap 5
- Chart.js
- Git y GitHub

## 3. Arquitectura

El proyecto utiliza tres capas de datos:

### RAW

Almacena la información original procedente de los archivos CSV.

Tablas:

- cat_perfil_riesgo
- catalogo_activos
- catalogo_banca
- historico_aba_macroactivos
- historico_aba_usd_internacional

### CORE

Contiene vistas SQL para transformar y consolidar información.

Incluye:

- Normalización de información.
- Identificación de fechas.
- Revisión de duplicados.
- Consolidación de posiciones locales.
- Preparación de posiciones internacionales.

### ANALYTICS

Contiene las vistas utilizadas para generar indicadores y alimentar el dashboard.

Incluye:

- Portafolio actual por cliente.
- Resumen de inversiones locales.
- Resumen de inversiones internacionales.
- Distribución por macroactivo.
- Características y segmentación de clientes.
- Concentración internacional por instrumento.

Flujo general:

CSV → RAW → CORE → ANALYTICS → DJANGO → DASHBOARD

## 4. Estructura del proyecto

```text
bancolombia-investment-analytics/
│
├── config/
├── dashboard/
│   ├── templates/
│   └── static/
│
├── scripts/
│   ├── cargar_csv.py
│   └── inicializar_proyecto.py
│
├── sql/
│   ├── 01_create_raw.sql
│   ├── ...
│   └── 16_analytics_concentracion_internacional.sql
│
├── data/
├── docker-compose.yml
├── manage.py
└── README.md
```

La carpeta `data/` debe crearse localmente y no debe publicarse con los datos originales.

## 5. Archivos de entrada

El proyecto requiere cinco archivos CSV:

1. cat_perfil_riesgo.csv
2. catalogo_activos.csv
3. catalogo_banca.csv
4. historico_aba_macroactivos.csv
5. historico_aba_usd_internacional.csv

Los archivos deben ubicarse en:

`data/`

Los CSV originales no están incluidos en GitHub.

## 6. Instalación y ejecución con Docker

Esta solución está diseñada para ejecutarse localmente
mediante Docker Compose.

El evaluador no necesita instalar PostgreSQL, Django
ni las dependencias de Python por separado.

### Requisitos previos

- Docker Desktop instalado y en ejecución.
- Git instalado, o descargar el proyecto como ZIP.
- Los cinco archivos CSV originales del ejercicio.

### Paso 1. Descargar el repositorio

Abrir PowerShell y ejecutar:

```powershell
git clone https://github.com/Diegoloy57/bancolombia-investment-analytics.git
cd bancolombia-investment-analytics
```

Alternativamente, descargar el ZIP desde GitHub
y extraerlo en una carpeta local.

### Paso 2. Preparar los archivos de entrada

Crear la carpeta `data` en la raíz del proyecto
si no existe:

```powershell
New-Item -ItemType Directory -Force data
```

Copiar allí los cinco archivos originales:

```text
data/
├── cat_perfil_riesgo.csv
├── catalogo_activos.csv
├── catalogo_banca.csv
├── historico_aba_macroactivos.csv
└── historico_aba_usd_internacional.csv
```

Estos archivos no se encuentran en el repositorio,
ya que fueron excluidos deliberadamente de Git.

El evaluador debe utilizar los CSV originales
suministrados para la prueba técnica.

### Paso 3. Configurar las variables de entorno

Crear el archivo `.env` a partir de la plantilla:

```powershell
Copy-Item .env.example .env
```

Abrir `.env` y reemplazar `CHANGE_ME` por una
contraseña local.

Ejemplo de configuración:

```dotenv
POSTGRES_HOST=127.0.0.1
POSTGRES_DB=bancolombia_analytics
POSTGRES_USER=bancolombia_app
POSTGRES_PASSWORD=CAMBIAR_POR_CONTRASENA_LOCAL
POSTGRES_PORT=5433
```

Docker Compose configura automáticamente la conexión
interna de Django con PostgreSQL mediante el servicio `db`.

El archivo `.env` no debe publicarse en GitHub.

### Paso 4. Iniciar Docker

Desde la carpeta raíz del proyecto ejecutar:

```powershell
docker compose up -d --build
```

Este comando construye la imagen de Django,
instala las dependencias de `requirements.txt`
y levanta PostgreSQL y Django.

Verificar el estado:

```powershell
docker compose ps
```

Los servicios `db` y `web` deben aparecer activos.
PostgreSQL debe indicar un estado saludable.

### Paso 5. Inicializar la base de datos

Ejecutar:

```powershell
docker compose exec web python scripts/inicializar_proyecto.py
```

El inicializador realiza automáticamente:

1. Creación de los esquemas y tablas RAW.
2. Carga de los cinco archivos CSV.
3. Validaciones de calidad y catálogos.
4. Construcción de las vistas CORE.
5. Construcción de las vistas ANALYTICS.
6. Verificación de los clientes procesados.

La ejecución correcta debe finalizar con:

```text
INICIALIZACION COMPLETADA
Clientes disponibles en el modelo: 32
```

Este resultado corresponde a los archivos originales
utilizados durante el desarrollo de la solución.

IMPORTANTE: La inicialización reemplaza los datos
existentes en las tablas RAW. No debe ejecutarse
sobre una base que contenga información que se
necesite conservar sin realizar una copia previa.

### Paso 6. Abrir el dashboard

Abrir un navegador web e ingresar a:

http://localhost:8000/dashboard/

El dashboard permite consultar:

- Portafolios de inversión locales en COP.
- Portafolios internacionales en USD.
- Distribución por macroactivos.
- Indicadores de calidad de datos.
- Características y segmentación de clientes.
- Concentración internacional por instrumento.

No se requiere publicar el proyecto en internet.

### Paso 7. Detener la aplicación

Para detener los contenedores:

```powershell
docker compose down
```

Este comando conserva los datos almacenados
en el volumen de PostgreSQL.

No utilizar `docker compose down -v` si se desea
conservar la base de datos.

## 7. Arquitectura de ejecución

Docker Compose administra dos servicios:

**PostgreSQL 17**

- Servicio: `db`
- Contenedor: `bancolombia_postgres`
- Puerto local: `5433`
- Almacenamiento persistente mediante volumen Docker.

**Django**

- Servicio: `web`
- Contenedor: `bancolombia_django`
- Puerto local: `8000`
- Interfaz disponible en `/dashboard/`.

La aplicación Django consulta las vistas SQL
de PostgreSQL para presentar los indicadores.

Flujo:

CSV → RAW → CORE → ANALYTICS → DJANGO → DASHBOARD

## 8. Reproducibilidad

La solución fue validada mediante Docker Compose.

En la ejecución de referencia se obtuvieron:

- 5 archivos CSV cargados.
- 12.474 registros de entrada.
- 16 scripts SQL ejecutados correctamente.
- 32 clientes identificados.

El proyecto utiliza un volumen local para compartir
los archivos del repositorio con el contenedor Django.

Por ello, los CSV deben encontrarse en `data/`
antes de ejecutar el inicializador.

Los resultados pueden variar si se utilizan
archivos de entrada diferentes.
```

## 9. Dashboard

El dashboard se encuentra disponible en:

http://localhost:8000/dashboard/

Permite:

- Seleccionar clientes.
- Consultar portafolios locales e internacionales.
- Visualizar distribuciones de inversión.
- Revisar indicadores de calidad.
- Consultar segmentación multidimensional.
- Analizar concentración internacional por instrumento.

## 10. Resultados analíticos

En el conjunto de datos utilizado se identificaron:

- 32 clientes distintos en el análisis consolidado.
- 31 clientes con posiciones locales.
- 13 clientes con posiciones internacionales registradas.
- 12 clientes con posiciones internacionales válidas y positivas para el análisis de concentración.
- 102 posiciones internacionales válidas con valor positivo.
- USD 8.830.776,37 de valor internacional agregado bajo los criterios de filtrado utilizados.

### Concentración internacional

Clasificación exploratoria por participación del instrumento principal:

| Clasificación | Criterio | Clientes |
|---|---|---:|
| Revisión prioritaria | Mayor o igual al 90 % | 2 |
| Seguimiento | Mayor o igual al 50 % y menor al 90 % | 3 |
| Concentración menor | Inferior al 50 % | 7 |

Estos umbrales son criterios exploratorios del proyecto y no corresponden a políticas oficiales de Bancolombia.

La concentración por instrumento no equivale necesariamente al riesgo financiero total, porque existen diferencias entre acciones individuales, bonos, fondos y ETF.

## 11. Calidad y limitaciones

El sistema contempla controles relacionados con:

- Duplicados.
- Fechas de portafolio.
- Identificadores de clientes.
- Clasificación de activos.
- Perfiles de riesgo.
- Registros aptos y no aptos para agregación.

Los resultados corresponden a datos históricos.

Las vistas de portafolio actual utilizan la última fecha disponible por cliente, que no necesariamente coincide entre todos los clientes.

Por esta razón, los valores agregados no deben interpretarse como una fotografía sincronizada de todos los portafolios.

## 12. Seguridad

- Los archivos CSV originales no se publican.
- Las credenciales se mantienen fuera del repositorio.
- El archivo `.env` debe permanecer excluido mediante `.gitignore`.
- El proyecto está destinado a análisis técnico y demostración.

## 13. Autor

Diego Andrés Loyo Osorio

Prueba técnica — Analítica de Inversiones
```
