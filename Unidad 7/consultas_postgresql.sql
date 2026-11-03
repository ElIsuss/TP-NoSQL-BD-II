-- TP Unidad 7: NoSQL y nuevas formas de almacenamiento
-- Base de origen: foodstore
-- Ejecutar en PostgreSQL con el usuario del entorno local.
-- No se consultan ni exportan nombres, correos o telefonos de clientes.
-- Los clientes se identifican en MongoDB con ID y etiqueta anonimizada.

-- 1. Inspeccionar la estructura (ejecutar en psql).
-- \d pedido
-- \d detalle_pedido
-- \d cliente
-- \d producto

-- 2. Cinco pedidos seleccionados, sin incluir registros eliminados.
SELECT id_pedido, fecha_hora, forma_pago, id_cliente, estado
FROM pedido
WHERE id_pedido IN (1, 2, 3, 4, 5)
  AND eliminado IS FALSE
ORDER BY id_pedido;

-- 3. Detalles y nombres de productos de los pedidos seleccionados.
SELECT dp.id_detalle_pedido,
       dp.id_pedido,
       dp.id_producto,
       pr.nombre AS producto,
       dp.cantidad,
       dp.precio_unitario
FROM detalle_pedido AS dp
JOIN pedido AS p
  ON p.id_pedido = dp.id_pedido
JOIN producto AS pr
  ON pr.id_producto = dp.id_producto
WHERE dp.id_pedido IN (1, 2, 3, 4, 5)
  AND p.eliminado IS FALSE
  AND dp.eliminado IS FALSE
ORDER BY dp.id_pedido, dp.id_detalle_pedido;

-- 4. Identificadores de clientes asociados (sin datos personales).
SELECT id_cliente
FROM cliente
WHERE id_cliente IN (5240, 13999, 8675, 5580, 10045)
ORDER BY id_cliente;

-- === Consultas equivalentes a MongoDB ===

-- b) Filtrar por estado PENDIENTE.
SELECT id_pedido, estado, forma_pago
FROM pedido
WHERE estado = 'PENDIENTE'
  AND id_pedido IN (1, 2, 3, 4, 5)
  AND eliminado IS FALSE
ORDER BY id_pedido;

-- c) Buscar pedidos que contengan el producto 3485.
SELECT DISTINCT p.id_pedido
FROM pedido AS p
JOIN detalle_pedido AS dp
  ON dp.id_pedido = p.id_pedido
WHERE dp.id_producto = 3485
  AND p.id_pedido IN (1, 2, 3, 4, 5)
  AND p.eliminado IS FALSE
  AND dp.eliminado IS FALSE
ORDER BY p.id_pedido;

-- d) Buscar pedidos cuyo total excede $250.000.
-- El total se calcula usando cantidad * precio_unitario historico.
SELECT p.id_pedido,
       SUM(dp.cantidad * dp.precio_unitario)::numeric(14, 2) AS total
FROM pedido AS p
JOIN detalle_pedido AS dp
  ON dp.id_pedido = p.id_pedido
WHERE p.id_pedido IN (1, 2, 3, 4, 5)
  AND p.eliminado IS FALSE
  AND dp.eliminado IS FALSE
GROUP BY p.id_pedido
HAVING SUM(dp.cantidad * dp.precio_unitario) > 250000
ORDER BY total DESC;
