/*  CONSULTA 1 
 Cruza ventas + clientes + productos + territorios en una sola fila. */

SELECT
    v.fecha_venta,
    c.nombre_cliente   AS cliente,
    c.segmento,
    t.region,
    p.nombre_producto  AS producto,
    p.categoria,
    v.cantidad,
    v.precio_unitario,
    v.total_venta,
    v.canal
FROM ventas v
INNER JOIN clientes    c ON v.id_cliente    = c.id_cliente
INNER JOIN productos   p ON v.id_producto   = p.id_producto
INNER JOIN territorios t ON c.id_territorio = t.id_territorio
ORDER BY v.fecha_venta;

/* Nota: se usa INNER JOIN con territorios porque todas las ventas actuales 
pertenecen a clientes con territorio asignado. Si en el futuro hubiera 
ventas de un cliente sin territorio (id_territorio NULL, como Roberto Díaz),
cambiariamos ese último JOIN por LEFT JOIN para no perder esas filas. */


/* CONSULTA 2 — Clientes sin ventas (LEFT JOIN)
Clientes registrados que aún no realizaron ninguna compra */

SELECT
    c.nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


/* CONSULTA 3 — Productos sin ventas (LEFT JOIN)
Artículos del catálogo que no tienen ninguna venta registrada. */

SELECT
    p.nombre_producto,
    p.categoria,
    p.precio
FROM productos p
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;


/* CONSULTA 4 — Consolidado por canal (UNION ALL)
Combinar las ventas Online y Presencial con UNION ALL y luego calcular el total de cada canal con GROUP BY. */

WITH ventas_consolidadas AS (
    SELECT canal, total_venta
    FROM ventas
    WHERE canal = 'Online'
    UNION ALL
    SELECT canal, total_venta
    FROM ventas
    WHERE canal = 'Presencial'
)
SELECT
    canal,
    COUNT(*)          AS cantidad_ventas,
    SUM(total_venta)  AS total_facturado
FROM ventas_consolidadas
GROUP BY canal;