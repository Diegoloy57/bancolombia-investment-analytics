
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


## 6. Configuración del entorno

### Requisitos previos

- Python
- Docker Desktop
- Git

### Clonar el repositorio

```bash
git clone https://github.com/Diegoloy57/bancolombia-investment-analytics.git
cd bancolombia-investment-analytics
```

### Crear el entorno virtual en Windows

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

### Instalar dependencias

```powershell
pip install -r requirements.txt
```

### Configurar variables de entorno

Copiar el archivo de ejemplo:

```powershell
Copy-Item .env.example .env
```

Revisar los valores de conexión a PostgreSQL
y establecer una contraseña local segura.

El archivo `.env` contiene información privada
y no debe publicarse en GitHub.

### Preparar los archivos CSV

Crear la carpeta `data/` si no existe:

```powershell
New-Item -ItemType Directory -Force data
```

Ubicar allí los cinco archivos CSV originales
antes de ejecutar el inicializador.
```


## 7. Ejecutar PostgreSQL y Django

Iniciar los contenedores:

```powershell
docker compose up -d --build
```

Comprobar su estado:

```powershell
docker compose ps
```

El proyecto utiliza PostgreSQL y Django mediante Docker Compose.

## 8. Inicialización de la base de datos

Una vez configurada la conexión y ubicados los CSV en la carpeta `data/`, ejecutar:

```powershell
python .\scripts\inicializar_proyecto.py
```

Este proceso realiza:

1. Creación de los esquemas y tablas RAW.
2. Carga de los cinco archivos CSV.
3. Ejecución de consultas de validación.
4. Construcción de las vistas CORE.
5. Construcción de las vistas ANALYTICS.
6. Verificación de los clientes disponibles.

La inicialización fue probada en una base independiente y produjo 32 clientes en la vista de segmentación multidimensional.

**Importante:** el proceso reemplaza el contenido de las tablas RAW mediante TRUNCATE. No debe ejecutarse sobre una base con información que deba conservarse sin realizar previamente una copia de seguridad.

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
