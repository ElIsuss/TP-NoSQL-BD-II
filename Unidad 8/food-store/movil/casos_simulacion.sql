-- TP 8: Food Store en la feria
-- Script de Ejecución de Casos de Simulación C2 a C6 (Consigna 2.c)
-- Ejecutable sobre SQLite con la base foodstore_movil.db

PRAGMA foreign_keys = ON;

-- =============================================================
-- CASO C2: Conflicto por suba de precio y posterior aceptación
-- =============================================================
-- 1. Se crea borrador con producto 101 al precio visto de $8500.00 (850000 centavos)
INSERT INTO pedido_borrador (id_local, usuario, forma_pago, fecha)
VALUES ('b2222222-2222-2222-2222-222222222222', 'mozo_feria_01', 'EFECTIVO', '2026-11-03 14:00:00');

INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
VALUES ('b2222222-2222-2222-2222-222222222222', 101, 1, 850000);

INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
VALUES ('s2222222-aaaa-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'PENDIENTE', 'Envio borrador C2');

-- 2. En el servidor sube el precio a $9200.00 (920000 centavos)
UPDATE snapshot_servidor SET precio_centavos = 920000 WHERE id = 101;

-- 3. Se corre el semáforo para evaluar solicitudes pendientes
-- (La lógica del semáforo actualiza cola_sync)
WITH diagnostico_items AS (
    SELECT 
        c.solicitud_uuid,
        CASE 
            WHEN s.id IS NULL OR s.eliminado = 't' OR s.disponible = 'f' OR i.cantidad > s.stock THEN 1 ELSE 0 
        END AS tiene_rechazo,
        CASE 
            WHEN s.id IS NOT NULL AND s.eliminado = 'f' AND s.disponible = 't' AND i.cantidad <= s.stock AND i.precio_centavos_visto <> s.precio_centavos THEN 1 ELSE 0 
        END AS tiene_conflicto,
        CASE 
            WHEN i.precio_centavos_visto <> s.precio_centavos THEN 
                'Cambio de precio en producto ' || i.producto_id || ' (visto: $' || (i.precio_centavos_visto/100.0) || ', actual: $' || (s.precio_centavos/100.0) || ')'
            ELSE NULL 
        END AS motivo_conflicto
    FROM cola_sync c
    JOIN item_borrador i ON i.id_local = c.id_local
    LEFT JOIN snapshot_servidor s ON s.id = i.producto_id
    WHERE c.estado = 'PENDIENTE'
),
resultado_solicitud AS (
    SELECT 
        solicitud_uuid,
        CASE 
            WHEN SUM(tiene_rechazo) > 0 THEN 'RECHAZADO'
            WHEN SUM(tiene_conflicto) > 0 THEN 'CONFLICTO'
            ELSE 'SIMULADO_APROBADO'
        END AS nuevo_estado,
        CASE 
            WHEN SUM(tiene_conflicto) > 0 THEN 'CONFLICTO: ' || GROUP_CONCAT(motivo_conflicto, '; ')
            ELSE 'SIMULADO_APROBADO'
        END AS nuevo_motivo
    FROM diagnostico_items
    GROUP BY solicitud_uuid
)
UPDATE cola_sync
SET 
    estado = (SELECT r.nuevo_estado FROM resultado_solicitud r WHERE r.solicitud_uuid = cola_sync.solicitud_uuid),
    motivo = (SELECT r.nuevo_motivo FROM resultado_solicitud r WHERE r.solicitud_uuid = cola_sync.solicitud_uuid)
WHERE estado = 'PENDIENTE'
  AND solicitud_uuid IN (SELECT solicitud_uuid FROM resultado_solicitud);

-- 4. El cliente acepta el nuevo precio: se actualiza el borrador y se crea una nueva solicitud
UPDATE item_borrador SET precio_centavos_visto = 920000 
WHERE id_local = 'b2222222-2222-2222-2222-222222222222' AND producto_id = 101;

INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
VALUES ('s2222222-bbbb-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'PENDIENTE', 'Reintento con nuevo precio aceptado');

-- =============================================================
-- CASO C3: Rechazo por stock insuficiente
-- =============================================================
-- Solicitud de 100 unidades de Papas Fritas (id 102) cuando el servidor solo dispone de 40
INSERT INTO pedido_borrador (id_local, usuario, forma_pago, fecha)
VALUES ('b3333333-3333-3333-3333-333333333333', 'mozo_feria_01', 'TARJETA', '2026-11-03 14:10:00');

INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
VALUES ('b3333333-3333-3333-3333-333333333333', 102, 100, 350000);

INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
VALUES ('s3333333-aaaa-3333-3333-333333333333', 'b3333333-3333-3333-3333-333333333333', 'PENDIENTE', 'Envio borrador C3');

-- =============================================================
-- CASO C4: Rechazo por baja lógica y recarga de catálogo
-- =============================================================
-- Borrador con producto 103 (Gaseosa)
INSERT INTO pedido_borrador (id_local, usuario, forma_pago, fecha)
VALUES ('b4444444-4444-4444-4444-444444444444', 'mozo_feria_02', 'TRANSFERENCIA', '2026-11-03 14:15:00');

INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
VALUES ('b4444444-4444-4444-4444-444444444444', 103, 2, 200000);

INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
VALUES ('s4444444-aaaa-4444-4444-444444444444', 'b4444444-4444-4444-4444-444444444444', 'PENDIENTE', 'Envio borrador C4');

-- En el servidor se da de baja lógica el producto 103
UPDATE snapshot_servidor SET eliminado = 't', disponible = 'f' WHERE id = 103;

-- =============================================================
-- CASO C5: Aprobación sin cambios
-- =============================================================
-- Borrador con producto 3485 (Empanadas), con datos perfectamente vigentes
INSERT INTO pedido_borrador (id_local, usuario, forma_pago, fecha)
VALUES ('b5555555-5555-5555-5555-555555555555', 'mozo_feria_01', 'EFECTIVO', '2026-11-03 14:20:00');

INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
VALUES ('b5555555-5555-5555-5555-555555555555', 3485, 5, 460206);

INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
VALUES ('s5555555-aaaa-5555-5555-555555555555', 'b5555555-5555-5555-5555-555555555555', 'PENDIENTE', 'Envio borrador C5');

