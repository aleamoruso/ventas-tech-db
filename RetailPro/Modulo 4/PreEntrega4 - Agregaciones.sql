
/* CONSULTA 1 — Resumen ejecutivo mensual
Total facturado, cantidad de pedidos y ticket promedio, por mes. */

SELECT
    MONTH(fecha_venta)                         AS mes,
    SUM(cantidad * precio_unitario)            AS total_facturado,
    COUNT(*)                                   AS cantidad_pedidos,
    ROUND(AVG(cantidad * precio_unitario), 2)  AS ticket_promedio
FROM Ventas_Tech_DB.dbo.ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


/* CONSULTA 2 — Ranking de productos (Top 5 por facturación)
Unidades vendidas y total generado por id_producto. */

SELECT TOP 5
    id_producto,
    SUM(cantidad)                    AS unidades_vendidas,
    SUM(cantidad * precio_unitario)  AS total_facturado
FROM Ventas_Tech_DB.dbo.ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;


/* CONSULTA 3 — Clientes recurrentes (más de un pedido)
Cantidad de pedidos y total gastado por id_cliente. */

SELECT
    id_cliente,
    COUNT(*)                         AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)  AS total_gastado
FROM Ventas_Tech_DB.dbo.ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

/* CONSULTA 4 — Meses por encima / por debajo del promedio
--  Total por mes + etiqueta comparando contra el promedio mensual general.*/

WITH ventas_por_mes AS (
    SELECT
        MONTH(fecha_venta)               AS mes,
        SUM(cantidad * precio_unitario)  AS total_mes
    FROM Ventas_Tech_DB.dbo.ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_mes,
    CASE
        WHEN total_mes >= (SELECT AVG(total_mes) FROM ventas_por_mes)
        THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM ventas_por_mes
ORDER BY mes;


/*  HALLAZGOS:

 1) El producto 1 genera el 55,9% de la facturación total.

 2) Todos los clientes son recurrentes. los 5 clientes hicieron 2 pedidos
 cada uno. El cliente 1 es el de mayor gasto (2.640) y el cliente 5 le sigue (2.100). Juntos explican
 cerca del 74% de la facturación.

 3) Toda la actividad se concentra en un único mes (marzo de 2024), por lo
 que el resumen mensual y la comparación contra el promedio devuelven un solo período. 
 Para un análisis temporal útil (estacionalidad, tendencia) haría falta cargar ventas de varios meses.  */
