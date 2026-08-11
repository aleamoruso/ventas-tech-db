# RetailPro — Proyecto de Data Analytics

Proyecto integral de análisis de datos para **RetailPro**, una empresa distribuidora de tecnología. Recorre todo el flujo del analista: desde el diseño del modelo de datos hasta el dashboard ejecutivo, trabajando sobre una base de ventas de tecnología (**Ventas_Tech_DB / TechStore**).

## Descripción

El repositorio reúne los entregables del proyecto, organizados por módulos. El proyecto tiene dos hilos complementarios:

- **RetailPro** — el caso de negocio y los entregables de diseño y visualización (brief estratégico, modelo relacional, boceto del dashboard).
- **Ventas_Tech_DB (TechStore)** — la base de datos SQL real sobre la que se ejecutan las consultas y se construye el modelo de Power BI.

## Herramientas

- **SQL Server** (T-SQL) — creación de la base de datos y consultas de negocio.
- **Power BI Desktop** — ETL con Power Query, modelo de datos y medidas DAX.
- **Excel** — dataset fuente del pipeline de limpieza.
- **GitHub** — versionado y entrega de los scripts.

## Estructura del repositorio

- `ventas_tech_db_v2.sql` — creación y carga de la base (5 tablas normalizadas).
- `m4_consultas_negocio.sql` — métricas de negocio (resumen mensual, ranking, recurrencia, comparación contra el promedio).
- `m5_consultas_joins.sql` — consultas con JOINs (vista enriquecida, clientes/productos sin ventas, consolidado por canal).
- `Pipeline_ETL_*.pbix` — pipeline de limpieza y transformación en Power BI.
- `*_Checkpoint2.pbix` — modelo con relaciones, tabla calendario y 5 medidas DAX.

## Cómo ejecutar los scripts SQL

**Motor: SQL Server.** Ejecutá en este orden (respeta las dependencias entre tablas):

1. **`ventas_tech_db_v2.sql`** — crea la base `Ventas_Tech_DB` y carga las 5 tablas. Es repetible (hace `DROP`/`CREATE`). Al terminar deberías tener **9 territorios, 4 categorías, 11 clientes, 12 productos y 50 ventas**.
2. **`m4_consultas_negocio.sql`** — consultas de resumen mensual, top de productos, clientes recurrentes y meses por encima/por debajo del promedio.
3. **`m5_consultas_joins.sql`** — vista base (INNER JOIN de 4 tablas), clientes y productos sin ventas (LEFT JOIN + `IS NULL`) y consolidado por canal (`UNION ALL`).

> **Nota:** las consultas están escritas en **T-SQL de SQL Server** (`MONTH()`, `SELECT TOP`, etc.), no en PostgreSQL. Si las corrés en otro motor, hay que adaptar esa sintaxis.

## Modelo de datos

Esquema en estrella: `ventas` (tabla de hechos) referencia a `clientes`, `productos` y `territorios` (dimensiones). `clientes` se vincula a `territorios` por `id_territorio`, y `productos` a `categorias` por el nombre de categoría.
