-- TP Unidad 7: NoSQL y nuevas formas de almacenamiento
-- Base de datos: foods_store_completo
-- Parte 1: inspeccion del modelo relacional y seleccion de pedidos

-- 1. Consultar la estructura de las tablas principales.
-- Ejecutar estos comandos en psql:
-- \d pedido
-- \d detalle_pedido
-- \d cliente
-- \d producto

-- 2. Obtener los primeros cinco pedidos seleccionados.
SELECT
    id_pedido,
    fecha_hora,
    forma_pago,
    id_cliente,
    estado
FROM pedido
ORDER BY id_pedido
LIMIT 5;

-- 3. Obtener los detalles y nombres de los productos de esos pedidos.
SELECT
    dp.id_detalle_pedido,
    dp.id_pedido,
    dp.id_producto,
    p.nombre AS producto,
    dp.cantidad,
    dp.precio_unitario
FROM detalle_pedido AS dp
JOIN producto AS p
    ON p.id_producto = dp.id_producto
WHERE dp.id_pedido IN (1, 2, 3, 4, 5)
ORDER BY dp.id_pedido, dp.id_detalle_pedido;

-- 4. Obtener los datos esenciales de los clientes de esos pedidos.
SELECT
    id_cliente,
    nombre,
    apellido,
    correo_electronico,
    telefono
FROM cliente
WHERE id_cliente IN (7424, 9972, 13218, 468, 16839)
ORDER BY id_cliente;
