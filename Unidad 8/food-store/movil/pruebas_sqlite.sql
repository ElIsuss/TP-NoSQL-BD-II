-- TP 8: Food Store en la feria
-- Script de pruebas del esquema SQLite (Consigna 1.c)
-- Ejecutable en SQLite 3.37+ con claves foráneas activadas

PRAGMA foreign_keys = ON;

-- -------------------------------------------------------------
-- Datos iniciales en producto_cache (Simulando catálogo cargado)
-- -------------------------------------------------------------
INSERT INTO producto_cache (id, nombre, precio_centavos, stock_visto, disponible, eliminado, fecha_de_copia) VALUES
(101, 'Hamburguesa Doble Queso', 850000, 25, 1, 0, '2026-11-03 12:00:00'),
(102, 'Papas Fritas Medianas',   350000, 40, 1, 0, '2026-11-03 12:00:00'),
(103, 'Gaseosa 500ml Cola',       200000, 50, 1, 0, '2026-11-03 12:00:00'),
(104, 'Cerveza Artesanal IPA',    450000,  0, 1, 0, '2026-11-03 12:00:00'), -- Sin stock
(105, 'Sandwich Vegano (Baja)',   700000, 10, 0, 1, '2026-11-03 12:00:00'); -- Dado de baja

-- =============================================================
-- 1. Transacción completa confirmada (BEGIN ... COMMIT)
-- =============================================================
BEGIN TRANSACTION;

INSERT INTO pedido_borrador (id_local, usuario, forma_pago, fecha)
VALUES ('b1111111-1111-1111-1111-111111111111', 'mozo_feria_01', 'EFECTIVO', '2026-11-03 13:15:00');

INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
VALUES ('b1111111-1111-1111-1111-111111111111', 101, 2, 850000);

INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
VALUES ('b1111111-1111-1111-1111-111111111111', 102, 1, 350000);

INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
VALUES ('s1111111-aaaa-bbbb-cccc-111111111111', 'b1111111-1111-1111-1111-111111111111', 'PENDIENTE', 'Borrador inicial feria');

COMMIT;

-- =============================================================
-- 2. Transacción deshecha con ROLLBACK (operación cancelada)
-- =============================================================
BEGIN TRANSACTION;

INSERT INTO pedido_borrador (id_local, usuario, forma_pago, fecha)
VALUES ('b9999999-9999-9999-9999-999999999999', 'mozo_feria_02', 'TARJETA', '2026-11-03 13:20:00');

INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
VALUES ('b9999999-9999-9999-9999-999999999999', 103, 5, 200000);

-- Se aborta la operación antes de persistir
ROLLBACK;

-- Verificación de ROLLBACK: debe devolver 0 filas
SELECT 'Verificacion ROLLBACK (debe dar 0 filas):' AS test, COUNT(*) AS filas_encontradas 
FROM pedido_borrador 
WHERE id_local = 'b9999999-9999-9999-9999-999999999999';

-- =============================================================
-- 3. Caso C1: Consulta del catálogo disponible local (Offline)
-- =============================================================
-- Consulta que realiza la tablet sin conexión al servidor central:
-- Muestra productos disponibles, no eliminados y con stock visible > 0.
SELECT 
    id, 
    nombre, 
    PRINTF('$%.2f', precio_centavos / 100.0) AS precio, 
    stock_visto,
    fecha_de_copia
FROM producto_cache
WHERE disponible = 1 
  AND eliminado = 0 
  AND stock_visto > 0
ORDER BY id;

-- =============================================================
-- 4. Caso C7: Violación de restricciones (cantidad cero y FK inexistente)
-- =============================================================
-- Subcaso 4.1: Intentar insertar ítem con cantidad = 0 (Debe fallar por CHECK)
-- Descomentar o ejecutar para observar el error: CHECK constraint failed: cantidad > 0
-- INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
-- VALUES ('b1111111-1111-1111-1111-111111111111', 103, 0, 200000);

-- Subcaso 4.2: Intentar insertar ítem con producto inexistente (Debe fallar por FOREIGN KEY)
-- Descomentar o ejecutar para observar el error: FOREIGN KEY constraint failed
-- INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
-- VALUES ('b1111111-1111-1111-1111-111111111111', 9999, 1, 500000);

-- Verificación final: Se comprueba que item_borrador solo tiene los 2 ítems legítimos del commit
SELECT 
    'Verificacion final de integridad (items legitimos):' AS test,
    i.id_local,
    p.nombre,
    i.cantidad,
    PRINTF('$%.2f', i.precio_centavos_visto / 100.0) AS precio_unitario
FROM item_borrador i
JOIN producto_cache p ON p.id = i.producto_id;

