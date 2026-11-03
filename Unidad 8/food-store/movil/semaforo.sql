-- TP 8: Food Store en la feria
-- Script del Semáforo de Sincronización (Consigna 2.b)
-- Evalúa borradores PENDIENTES contrastando con snapshot_servidor

PRAGMA foreign_keys = ON;

-- 1. Tabla que almacena la instantánea recibida del servidor PostgreSQL
CREATE TABLE IF NOT EXISTS snapshot_servidor (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    precio_centavos INTEGER NOT NULL,
    stock INTEGER NOT NULL,
    disponible TEXT NOT NULL, -- 't' o 'f' proveniente del CSV de psql
    eliminado TEXT NOT NULL   -- 't' o 'f' proveniente del CSV de psql
);

-- 2. Actualización de la caché local de la tablet a partir del snapshot del servidor
INSERT OR REPLACE INTO producto_cache (id, nombre, precio_centavos, stock_visto, disponible, eliminado, fecha_de_copia)
SELECT 
    id,
    nombre,
    precio_centavos,
    stock,
    CASE WHEN disponible = 't' THEN 1 ELSE 0 END,
    CASE WHEN eliminado = 't' THEN 1 ELSE 0 END,
    datetime('now')
FROM snapshot_servidor;

-- 3. Evaluación del Semáforo (Solo procesa solicitudes PENDIENTE)
-- Prioridades:
-- 1) RECHAZADO: producto inexistente, dado de baja, no disponible o stock insuficiente.
-- 2) CONFLICTO: sin causales de rechazo, pero con precio diferente al del servidor.
-- 3) SIMULADO_APROBADO: todos los productos existen, disponibles, con stock y precios idénticos.

WITH diagnostico_items AS (
    SELECT 
        c.solicitud_uuid,
        i.id_local,
        i.producto_id,
        i.cantidad,
        i.precio_centavos_visto,
        s.id AS server_id,
        s.precio_centavos AS server_precio,
        s.stock AS server_stock,
        s.disponible AS server_disponible,
        s.eliminado AS server_eliminado,
        -- Banderas de evaluación por línea
        CASE 
            WHEN s.id IS NULL THEN 1 
            WHEN s.eliminado = 't' THEN 1 
            WHEN s.disponible = 'f' THEN 1 
            WHEN i.cantidad > s.stock THEN 1 
            ELSE 0 
        END AS tiene_rechazo,
        CASE 
            WHEN s.id IS NOT NULL 
             AND s.eliminado = 'f' 
             AND s.disponible = 't' 
             AND i.cantidad <= s.stock 
             AND i.precio_centavos_visto <> s.precio_centavos THEN 1 
            ELSE 0 
        END AS tiene_conflicto,
        -- Detalle descriptivo de rechazo si aplica
        CASE 
            WHEN s.id IS NULL THEN 'Producto ' || i.producto_id || ' inexistente'
            WHEN s.eliminado = 't' THEN 'Producto ' || i.producto_id || ' dado de baja lógica'
            WHEN s.disponible = 'f' THEN 'Producto ' || i.producto_id || ' no disponible'
            WHEN i.cantidad > s.stock THEN 'Stock insuficiente para producto ' || i.producto_id || ' (solicitado: ' || i.cantidad || ', stock: ' || s.stock || ')'
            ELSE NULL 
        END AS motivo_rechazo,
        -- Detalle descriptivo de conflicto si aplica
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
            WHEN SUM(tiene_rechazo) > 0 THEN 
                'RECHAZADO: ' || GROUP_CONCAT(motivo_rechazo, '; ')
            WHEN SUM(tiene_conflicto) > 0 THEN 
                'CONFLICTO: ' || GROUP_CONCAT(motivo_conflicto, '; ')
            ELSE 'SIMULADO_APROBADO: Todos los productos validados con stock y precios vigentes'
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

-- 4. Consulta de inspección de estado de la cola de sincronización
SELECT 
    solicitud_uuid,
    id_local,
    estado,
    motivo
FROM cola_sync
ORDER BY solicitud_uuid;

