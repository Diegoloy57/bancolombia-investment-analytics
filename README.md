# Investment Analytics — Análisis de Portafolios de Inversión

Proyecto de analítica de inversiones desarrollado como solución a la prueba técnica de **Valores Bancolombia — Vicepresidencia de Estructuración, Mercado de Capitales**.

La solución integra PostgreSQL, SQL, Python, Django y Docker para procesar información histórica de inversiones, validar su calidad, consolidar portafolios y presentar resultados mediante un dashboard interactivo.

Incluye un **Radar de Clientes**, diseñado para identificar variaciones históricas del ABA y apoyar la priorización de revisiones comerciales y analíticas.

## 1. Objetivo del proyecto

Construir una solución reproducible que permita:

- Cargar automáticamente cinco archivos CSV en PostgreSQL.
- Validar, limpiar y transformar información mediante SQL.
- Consolidar portafolios locales e internacionales.
- Consultar el portafolio de cada cliente según la última fecha disponible.
- Analizar distribución, concentración y calidad de las inversiones.
- Segmentar clientes mediante características de sus portafolios.
- Identificar variaciones históricas del ABA para apoyar el seguimiento comercial.
- Explorar modelos de machine learning y evaluar su utilidad mediante pruebas temporales.

El proyecto está orientado al análisis de información histórica y no ejecuta operaciones financieras.

## 2. Tecnologías utilizadas

| Tecnología | Función |
|---|---|
| Python | Automatización de carga, inicialización y experimentos analíticos |
| PostgreSQL 17 | Almacenamiento y procesamiento de información |
| SQL | Limpieza, validación, transformación y análisis |
| Django 5.2 | Aplicación web y consultas a PostgreSQL |
| HTML, CSS y JavaScript | Interfaz interactiva |
| Bootstrap 5 | Diseño adaptable |
| Chart.js | Visualización de indicadores |
| Docker y Docker Compose | Ejecución reproducible |
| Git y GitHub | Control de versiones |
| scikit-learn | Experimentos de machine learning |

## 3. Arquitectura

El proyecto sigue un flujo de procesamiento por capas:

```text
Archivos CSV originales
         |
         v
Python - Carga automática
         |
         v
PostgreSQL
         |
         +-- RAW
         |   Datos originales
         |
         +-- CORE
         |   Validación, limpieza y consolidación
         |
         +-- ANALYTICS
         |   Vistas e indicadores analíticos
         |
         v
Django
         |
         +-- Consultas de portafolios
         +-- Indicadores de calidad
         +-- Segmentación de clientes
         +-- Concentración internacional
         +-- Radar de Clientes
         |
         v
Dashboard web interactivo
```

La mayor parte de la transformación y consolidación se realiza mediante SQL.

Python se utiliza principalmente para automatizar la carga y ejecutar los experimentos analíticos.

## 4. Archivos de entrada

La solución utiliza los siguientes cinco archivos:

| Archivo | Descripción |
|---|---|
| `cat_perfil_riesgo.csv` | Catálogo de perfiles de riesgo |
| `catalogo_activos.csv` | Catálogo de activos |
| `catalogo_banca.csv` | Catálogo de segmentos de banca |
| `historico_aba_macroactivos.csv` | Histórico de inversiones locales |
| `historico_aba_usd_internacional.csv` | Histórico de inversiones internacionales |

Los archivos deben ubicarse en la carpeta `data/`.

**Importante:** los CSV originales no se incluyen en el repositorio público. Deben ser suministrados por separado al evaluador autorizado.

La carpeta `data/` y el archivo `.env` están excluidos del control de versiones mediante `.gitignore`.

## 5. Organización del proyecto

```text
bancolombia-investment-analytics/
|
|-- config/
|   |-- settings.py
|   |-- urls.py
|
|-- dashboard/
|   |-- templates/
|   |   |-- dashboard/
|   |       |-- inicio.html
|   |
|   |-- static/
|   |   |-- dashboard/
|   |       |-- css/
|   |           |-- styles.css
|   |
|   |-- views.py
|   |-- urls.py
|
|-- scripts/
|   |-- cargar_csv.py
|   |-- inicializar_proyecto.py
|   |-- entrenar_modelo.py
|   |-- entrenar_clasificador.py
|
|-- sql/
|   |-- 01_create_raw.sql
|   |-- 02_validacion_calidad.sql
|   |-- 03_validar_catalogos.sql
|   |-- 04_crear_core.sql
|   |-- 05_core_fechas.sql
|   |-- 06_core_duplicados.sql
|   |-- 07_core_consolidado.sql
|   |-- 08_analytics_portafolio.sql
|   |-- 09_analytics_resumen_cliente.sql
|   |-- 10_analytics_distribucion.sql
|   |-- 11_core_internacional.sql
|   |-- 12_analytics_internacional.sql
|   |-- 13_analytics_resumen_internacional.sql
|   |-- 14_analytics_caracteristicas_clientes.sql
|   |-- 15_analytics_segmentacion_multidimensional.sql
|   |-- 16_analytics_concentracion_internacional.sql
|   |-- 17_analytics_aba_diario_predictivo.sql
|   |-- 18_analytics_variables_predictivas.sql
|   |-- 19_analytics_radar_clientes.sql
|
|-- data/
|   |-- Archivos CSV privados
|
|-- Dockerfile
|-- docker-compose.yml
|-- requirements.txt
|-- .env.example
|-- .gitignore
|-- manage.py
|-- README.md
```

## 6. Instalación y ejecución

### Requisitos

- Git
- Docker Desktop con Docker Compose
- Los cinco archivos CSV originales
- Puertos locales 8000 y 5433 disponibles

### Paso 1. Clonar el repositorio

```bash
git clone https://github.com/Diegoloy57/bancolombia-investment-analytics.git

cd bancolombia-investment-analytics
```

### Paso 2. Incorporar los datos

Crear la carpeta `data/`, si no existe, y copiar allí los cinco archivos CSV originales, conservando sus nombres.

### Paso 3. Configurar las variables de entorno

Crear un archivo `.env` en la raíz del proyecto, tomando como referencia `.env.example`.

La configuración debe proporcionar las siguientes variables:

```dotenv
POSTGRES_DB=bancolombia_analytics
POSTGRES_USER=bancolombia_app
POSTGRES_PASSWORD=REEMPLAZAR_POR_CONTRASENA_SEGURA
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5433
```

Reemplazar el valor de `POSTGRES_PASSWORD` por una contraseña privada.

En Docker, la comunicación interna entre Django y PostgreSQL utiliza el servicio `db`, según la configuración de Docker Compose.

No publicar el archivo `.env` ni sus contraseñas.

### Paso 4. Construir y ejecutar los contenedores

```bash
docker compose up -d --build
```

Verificar que los servicios estén funcionando:

```bash
docker compose ps
```

### Paso 5. Inicializar la base de datos

Con los contenedores activos y los CSV disponibles, ejecutar:

```bash
docker compose exec web python scripts/inicializar_proyecto.py
```

El inicializador:

1. Crea los esquemas y tablas RAW.
2. Carga los cinco CSV.
3. Ejecuta los scripts SQL restantes en orden.
4. Construye las capas CORE y ANALYTICS.
5. Comprueba la disponibilidad del modelo de segmentación.

Los scripts SQL se descubren automáticamente mediante sus nombres y se ejecutan ordenados.

**Nota de reproducibilidad:** estos comandos representan el procedimiento previsto de instalación. La prueba completa sobre una clonación limpia debe verificarse antes de considerar validada la entrega final.

### Paso 6. Abrir el dashboard

Con Django funcionando, abrir:

http://localhost:8000/dashboard/

### Paso 7. Comprobar Django

```bash
docker compose exec web python manage.py check
```

### Detener los servicios

```bash
docker compose down
```

Este comando detiene los contenedores sin solicitar la eliminación del volumen persistente de PostgreSQL.

## 7. Procesamiento y validación de datos

La solución utiliza tres capas.

### RAW

Conserva los datos recibidos de los archivos originales para permitir trazabilidad y análisis de calidad.

### CORE

Realiza operaciones como:

- Validación de estructuras y fechas.
- Identificación de registros duplicados.
- Revisión de valores numéricos.
- Cruces con catálogos.
- Consolidación de información.
- Identificación de registros que requieren revisión.

### ANALYTICS

Contiene vistas orientadas al consumo analítico y al dashboard.

Permite consultar resúmenes, distribuciones, segmentaciones y comportamientos históricos sin repetir la lógica de transformación en Django.

## 8. Dashboard de inversiones

El dashboard permite seleccionar un cliente y consultar sus portafolios.

### Portafolio local

Presenta:

- Valor ABA reportado.
- Cantidad de posiciones.
- Fecha de referencia.
- Distribución por macroactivo.
- Indicadores de identificación y calidad.

### Portafolio internacional

Presenta:

- Valor de mercado reportado.
- Cantidad de posiciones.
- Registros aptos para agregación.
- Registros en revisión.
- Fecha de referencia.

Los valores locales e internacionales se muestran por separado.

**No se suman COP y USD sin una conversión y una metodología financiera explícitas.**

## 9. Análisis y segmentación de clientes

La vista:

`analytics.vw_segmentacion_multidimensional`

permite caracterizar clientes a partir de:

- Perfil de riesgo disponible.
- Concentración por macroactivo.
- Variedad de activos.
- Participación en mercados locales e internacionales.
- Calidad de los identificadores.

El dashboard presenta indicadores, una gráfica de distribución y una tabla por cliente.

La segmentación es exploratoria y no constituye una calificación oficial de riesgo.

## 10. Concentración internacional

La vista:

`analytics.vw_concentracion_internacional`

identifica el instrumento de mayor valor dentro del portafolio internacional válido de cada cliente.

La concentración se calcula como:

```text
Concentración (%) =
Valor del instrumento principal
-------------------------------- x 100
Valor total del portafolio válido
```

Se utilizan categorías exploratorias:

| Clasificación | Criterio |
|---|---|
| Revisión prioritaria | Concentración desde 90 % |
| Seguimiento | Concentración desde 50 % y menor de 90 % |
| Concentración menor | Concentración inferior a 50 % |

Estos umbrales son criterios del proyecto, no políticas oficiales de Bancolombia.

La concentración por instrumento tampoco equivale necesariamente a concentración por emisor.

## 11. Radar de Clientes

El Radar permite identificar clientes con variaciones relevantes en su ABA histórico.

Su objetivo es apoyar la revisión de comportamientos que podrían resultar útiles para la gestión comercial y analítica.

### Construcción del Radar

El procesamiento utiliza tres vistas:

**`analytics.vw_aba_diario_predictivo`**

Construye una serie histórica de ABA por cliente y fecha, aplicando controles de duplicados, fechas y valores.

**`analytics.vw_variables_predictivas`**

Calcula variables históricas, entre ellas variaciones respecto a observaciones anteriores.

**`analytics.vw_radar_clientes`**

Selecciona la última observación disponible por cliente y clasifica su comportamiento.

### Reglas de clasificación

| Estado | Regla |
|---|---|
| Oportunidad | Variación anterior superior a +1 % |
| Estable | Variación entre -1 % y +1 %, inclusive |
| Seguimiento | Variación anterior inferior a -1 % |

Los nombres de las categorías son etiquetas operativas exploratorias.

Un aumento no garantiza una oportunidad comercial y una disminución no demuestra pérdida financiera.

### Resultados de la muestra analizada

| Indicador | Resultado |
|---|---:|
| Clientes incluidos en el Radar | 29 |
| Clientes estables | 17 |
| Clientes con aumento del ABA | 11 |
| Clientes para seguimiento | 1 |
| Última fecha observada | 15/05/2024 |

Estos resultados corresponden al conjunto histórico utilizado durante el desarrollo y pueden cambiar si se cargan nuevos datos.

### Funcionalidades visuales

El Radar está integrado al dashboard y permite:

- Consultar indicadores generales.
- Filtrar por comportamiento.
- Revisar el ABA y las variaciones históricas.
- Consultar la última fecha disponible.
- Abrir el portafolio individual de un cliente.

### Endpoint del Radar

```text
GET /dashboard/radar/
```

Filtros disponibles:

```text
/dashboard/radar/?estado=Estable
/dashboard/radar/?estado=Oportunidad
/dashboard/radar/?estado=Seguimiento
```

El endpoint devuelve información en formato JSON.

## 12. Experimentos de machine learning

Se desarrollaron experimentos para explorar la posibilidad de anticipar variaciones del ABA.

Estos experimentos se mantienen separados del Radar descriptivo porque los resultados de validación todavía no justifican utilizar sus predicciones para decisiones comerciales automáticas.

### Preparación de los datos

Se construyeron variables históricas utilizando observaciones anteriores y posteriores de cada cliente.

Se aplicó una separación temporal entre entrenamiento y evaluación para evitar una división aleatoria que mezclara información del futuro con el pasado.

### Modelos evaluados

Se exploraron:

- Regresión lineal.
- Random Forest Regressor.
- Random Forest Classifier.

### Resultados de regresión

| Modelo | MAE aproximado |
|---|---:|
| Referencia: persistencia del último ABA | 8.420.614 |
| Regresión lineal con variación limitada | 8.872.912 |
| Random Forest Regressor | 9.874.303 |

En esta evaluación, los modelos probados no superaron la referencia sencilla de mantener el último valor observado.

### Resultados de clasificación

Se entrenó un clasificador para tres categorías:

- Seguimiento.
- Estable.
- Oportunidad.

La evaluación temporal incluyó 839 observaciones.

| Métrica | Resultado aproximado |
|---|---:|
| Exactitud del clasificador | 57 % |
| Exactitud de clasificar siempre como estable | 81 % |
| F1 macro del clasificador | 0,42 |
| F1 macro de la referencia estable | 0,30 |

El clasificador obtuvo cierta capacidad de identificación de clases minoritarias, pero produjo suficientes errores como para no considerarlo listo para uso operativo.

### Interpretación

Los resultados muestran por qué es necesario comparar cualquier modelo con una referencia simple.

Una solución de machine learning no debe considerarse superior únicamente por utilizar algoritmos más complejos.

Por esta razón, el dashboard utiliza actualmente reglas descriptivas verificables.

### Limitaciones

- Los datos representan un período histórico limitado.
- La frecuencia de observaciones no necesariamente equivale a días calendario consecutivos.
- La variable ABA no debe interpretarse automáticamente como rentabilidad.
- Los cambios pueden reflejar aportes, retiros, valoraciones u otras condiciones.
- Se requiere mayor validación temporal y financiera antes de utilizar predicciones en producción.

Los scripts de entrenamiento están disponibles como material experimental. Su ejecución requiere las dependencias correspondientes de análisis y machine learning en el entorno Python.

## 13. Resultados de validación durante el desarrollo

La carga inicial produjo los siguientes conteos:

| Tabla de origen | Registros |
|---|---:|
| Perfil de riesgo | 4 |
| Catálogo de activos | 20 |
| Catálogo de banca | 6 |
| Histórico local | 6.694 |
| Histórico internacional | 5.750 |

Para la serie histórica depurada del Radar se obtuvieron:

| Indicador | Resultado |
|---|---:|
| Observaciones de ABA diario | 3.250 |
| Clientes presentes en la serie | 32 |
| Fechas distintas | 112 |
| Clientes con historial suficiente para variables | 29 |
| Ejemplos utilizables para entrenamiento | 3.064 |

Los conteos documentan las pruebas realizadas durante el desarrollo. No son garantías sobre archivos de entrada diferentes.

## 14. Calidad y trazabilidad

Durante el análisis se identificaron registros duplicados, valores ausentes y algunos conflictos entre posiciones aparentemente equivalentes.

El procesamiento predictivo evita sumar indiscriminadamente duplicados y excluye determinadas observaciones con problemas de calidad.

**Limitación conocida:** el script `17_analytics_aba_diario_predictivo.sql` contiene exclusiones explícitas de fechas con información incompleta detectadas en el conjunto suministrado.

Esta regla debe generalizarse mediante una validación automática antes de considerar el procesamiento completamente independiente de las particularidades de la muestra.

## 15. Seguridad y tratamiento de datos

El repositorio no debe contener:

- CSV originales con información de clientes.
- Credenciales o contraseñas.
- Archivos `.env` privados.
- Datos sensibles exportados desde PostgreSQL.

La información se procesa localmente en el entorno autorizado.

El proyecto es un prototipo técnico y no incorpora, por sí solo, todos los controles necesarios para operar en un entorno financiero productivo.

## 16. Estado de implementación

| Componente | Estado |
|---|---|
| Base de datos PostgreSQL | Implementado |
| Carga automática de cinco CSV | Implementado |
| Transformaciones SQL | Implementado |
| Consolidación de portafolios | Implementado |
| Dashboard Django | Implementado |
| Análisis local e internacional | Implementado |
| Indicadores de calidad | Implementado |
| Segmentación multidimensional | Implementado |
| Concentración internacional | Implementado |
| Radar histórico de clientes | Implementado |
| Experimentos de machine learning | Evaluados, no operativos |
| Enriquecimiento con fuentes externas de mercado | Pendiente |
| Prueba completa desde clonación limpia | Pendiente de validación final |

## 17. Próximas mejoras

Las siguientes actividades permitirían ampliar la solución:

1. Incorporar información externa de mercado sobre activos locales e internacionales, documentando fuentes, fechas y correspondencia con los instrumentos del catálogo.
2. Automatizar completamente las reglas de exclusión por calidad en la serie histórica.
3. Verificar una instalación desde cero utilizando únicamente el repositorio, los CSV autorizados y la configuración documentada.
4. Confirmar que las dependencias de machine learning estén declaradas para reproducir los experimentos.
5. Ampliar la validación temporal de los modelos predictivos.
6. Incorporar pruebas automatizadas de integridad y consistencia.
7. Reforzar los controles de acceso y seguridad antes de cualquier uso productivo.

## 18. Enfoque de negocio

La solución busca transformar registros históricos en información que permita responder preguntas como:

- ¿Cuál es la composición del portafolio de un cliente?
- ¿Qué clientes presentan concentración elevada?
- ¿Qué inversiones requieren revisión de calidad?
- ¿Qué clientes tienen presencia local e internacional?
- ¿Cuáles muestran aumentos o disminuciones recientes del ABA?
- ¿Qué clientes conviene revisar primero y por qué?
- ¿Qué limitaciones deben considerarse antes de utilizar modelos predictivos?

El valor principal del proyecto está en conectar la calidad de los datos, el análisis financiero descriptivo y la visualización para facilitar decisiones informadas.

---

**Proyecto desarrollado para la prueba técnica de Valores Bancolombia — Analítica de Inversiones.**

**Repositorio:** https://github.com/Diegoloy57/bancolombia-investment-analytics