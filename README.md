# RetailPro — Proyecto de Data Analytics

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

```
/modulo-3/ventas_tech_db_v2.sql          -- creación y carga de la base (5 tablas)
/modulo-4/m4_consultas_negocio.sql       -- métricas de negocio
/modulo-5/m5_consultas_joins.sql         -- consultas con JOINs
/modulo-6/Pipeline_ETL_Apellido_Nombre.pbix  -- pipeline de limpieza (Power BI)
/modulo-8/Apellido_Nombre_Checkpoint2.pbix    -- modelo con relaciones, calendario y DAX
/README.md
```

## Cómo ejecutar los scripts SQL

**Motor: SQL Server.** Ejecutá en este orden (respeta las dependencias entre tablas):

1. **`ventas_tech_db_v2.sql`** — crea la base `Ventas_Tech_DB` y carga las 5 tablas. Es repetible (hace `DROP`/`CREATE`). Al terminar deberías tener **9 territorios, 4 categorías, 11 clientes, 12 productos y 50 ventas**.
2. **`m4_consultas_negocio.sql`** — resumen mensual, top de productos, clientes recurrentes y meses por encima/por debajo del promedio.
3. **`m5_consultas_joins.sql`** — vista base (INNER JOIN de 4 tablas), clientes y productos sin ventas (LEFT JOIN + `IS NULL`) y consolidado por canal (`UNION ALL`).

> **Nota:** las consultas están escritas en **T-SQL de SQL Server** (`MONTH()`, `SELECT TOP`, etc.), no en PostgreSQL.

## Modelo de datos

Esquema en estrella: `ventas` (tabla de hechos) referencia a `clientes`, `productos` y `territorios` (dimensiones). `clientes` se vincula a `territorios` por `id_territorio`, y `productos` a `categorias`.
---

## Pipeline ETL (Módulo 6): limpieza y decisiones

El dataset crudo (`Pipeline_ETL_Dataset.xlsx`) se conectó a Power BI y se limpió con Power Query. Presentaba problemas intencionales de calidad que se resolvieron con criterio técnico.

### Problemas detectados y resueltos

- **Duplicados:** `id_cliente = 1` (María López) y `id_producto = 103` (Monitor 4K) venían cargados dos veces. Se eliminaron con **Quitar duplicados** sobre la columna de ID (no sobre todas las columnas), porque el ID es la clave primaria y debe ser único para que las relaciones del modelo funcionen.

### Decisiones ante registros nulos críticos

En todos los casos se optó por **conservar** el registro y reemplazar el nulo, en lugar de eliminar la fila, para no perder información ni transacciones asociadas. Por eso los conteos finales quedan en 11 clientes y 12 productos (se elimina solo 1 duplicado por tabla).

| Registro | Campo nulo | Decisión | Justificación |
|---|---|---|---|
| Valentina Paz (cliente) | `email` | Reemplazar por **"Sin dato"** | El cliente tiene ventas asociadas; eliminarlo perdería esas transacciones. El email es un dato de contacto, no una clave para el análisis. |
| Roberto Díaz (cliente) | `ciudad` | Reemplazar por **"Sin datos"** | Una ciudad faltante no invalida al cliente. Además es el caso de "cliente sin ventas" usado en el análisis de CRM (M5), así que conviene conservarlo. |
| SSD Externo 1TB (producto) | `precio` | Reemplazar por **130** (precio de venta observado) | El producto tiene ventas registradas: eliminarlo dejaría esas transacciones huérfanas en el Merge. Un precio nulo impediría calcular ingresos, por eso se completa con su precio real observado. |
| Laptop Gaming Pro (producto) | `categoria` | Asignar **"Computación"** | Su subcategoría es "Laptops" y todas las laptops pertenecen a esa categoría. Es más útil para el análisis que marcarlo "Sin Categoría". |

### Transformaciones adicionales

- **Tipos de datos** corregidos en todas las tablas (IDs y cantidades como número entero, fechas como fecha, montos como decimal, textos como texto).
- **Nomenclatura profesional:** `clientes → Dim_Clientes`, `productos → Dim_Productos`, `categorias → Dim_Categorias`, `ventas → Fact_Ventas`.
- **Merge:** se enriqueció `Fact_Ventas` combinándola con `Dim_Productos` por `id_producto`, expandiendo `nombre_producto` y `categoria`.

### Comentarios documentados en el Editor Avanzado (lenguaje M)

Se agregaron comentarios técnicos (`//`) en las consultas para justificar los pasos clave del pipeline:

**Dim_Clientes**
```m
// Se quitan duplicados por id_cliente porque es la PK de Dim_Clientes:
// un id repetido rompería la relación 1:N con Fact_Ventas y duplicaría
// las ventas del cliente al propagarse por el modelo.

// El email nulo se reemplaza por "Sin dato" en vez de borrar la fila:
// el cliente tiene ventas, y eliminarlo perdería esas transacciones.
```

**Dim_Productos**
```m
// El precio nulo (SSD Externo 1TB) se reemplaza por su precio de venta
// observado (130) en lugar de eliminar el producto, que tiene ventas
// registradas y quedaría huérfano en el merge con Fact_Ventas.

// La categoría nula (Laptop Gaming Pro) se asigna a "Computación": su
// subcategoría es "Laptops" y el resto de las laptops vive en esa categoría.
```

### Verificación de cierre

Antes de **Cerrar y aplicar** se verificó que ninguna consulta tuviera errores y que los conteos fueran coherentes: **Dim_Clientes 11, Dim_Productos 12, Fact_Ventas 50, Dim_Categorias 4**.
