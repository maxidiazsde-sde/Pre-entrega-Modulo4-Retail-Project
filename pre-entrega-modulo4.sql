
-- =========================================
-- PRE-ENTREGA MÓDULO 4
-- CONSULTAS MULTICAPA PARA ANÁLISIS DE NEGOCIO
-- =========================================

-- ==========================================================
-- CONSULTA 1 - RENTABILIDAD POR CATEGORÍA
-- Problema de negocio:
-- Permite conocer qué categorías generan mayor volumen
-- de ventas e ingresos para orientar decisiones comerciales.
-- ==========================================================

SELECT
    p.categoria,
    SUM(v.cantidad) AS unidades_vendidas,
    SUM(v.cantidad * p.precio) AS ingreso_total
FROM ventas v
JOIN productos p
    ON v.id_producto = p.id_producto
GROUP BY p.categoria
HAVING SUM(v.cantidad) > 2;


-- ==========================================================
-- CONSULTA 2 - CLIENTES SIN COMPRAS
-- Problema de negocio:
-- Permite identificar clientes registrados que aún no
-- realizaron compras para futuras campañas comerciales.
-- ==========================================================

SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    COALESCE(COUNT(v.id_venta),0) AS cantidad_compras
FROM clientes c
LEFT JOIN ventas v
    ON c.id_cliente = v.id_cliente
GROUP BY
    c.id_cliente,
    c.nombre,
    c.apellido
HAVING COUNT(v.id_venta) = 0;


-- ==========================================================
-- CONSULTA 3 - TOP DE COMPRAS POR CLIENTE
-- Problema de negocio:
-- Permite identificar el producto que más compró cada cliente
-- y conocer la fecha de su última transacción.
-- ==========================================================

WITH ranking AS (
    SELECT
        c.id_cliente,
        c.nombre,
        c.apellido,
        p.nombre AS producto,
        COUNT(v.id_venta) AS veces_comprado,
        MAX(v.fecha) AS ultima_compra,
        ROW_NUMBER() OVER (
            PARTITION BY c.id_cliente
            ORDER BY COUNT(v.id_venta) DESC
        ) AS posicion
    FROM clientes c
    JOIN ventas v
        ON c.id_cliente = v.id_cliente
    JOIN productos p
        ON v.id_producto = p.id_producto
    GROUP BY
        c.id_cliente,
        c.nombre,
        c.apellido,
        p.nombre
)

SELECT
    nombre || ' ' || apellido AS cliente,
    producto,
    veces_comprado,
    ultima_compra
FROM ranking
WHERE posicion = 1
ORDER BY cliente;
