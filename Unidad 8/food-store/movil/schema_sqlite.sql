-- TP 8: Food Store en la feria
-- Script de inicialización de esquema SQLite para dispositivo móvil (Tablet)
-- Consigna 1.b: Las tablas (Modo STRICT)

PRAGMA foreign_keys = ON;

-- Eliminación previa para garantizar idempotencia en la creación
DROP TABLE IF EXISTS cola_sync;
DROP TABLE IF EXISTS item_borrador;
DROP TABLE IF EXISTS pedido_borrador;
DROP TABLE IF EXISTS producto_cache;
DROP TABLE IF EXISTS snapshot_servidor;

-- 1. Staging de la instantánea recibida desde PostgreSQL
CREATE TABLE snapshot_servidor (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    precio_centavos INTEGER NOT NULL,
    stock INTEGER NOT NULL,
    disponible TEXT NOT NULL CHECK (disponible IN ('t', 'f')),
    eliminado TEXT NOT NULL CHECK (eliminado IN ('t', 'f'))
);

-- 2. Tabla de caché local de productos (instantánea de solo lectura del servidor)
CREATE TABLE producto_cache (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    precio_centavos INTEGER NOT NULL CHECK (precio_centavos >= 0),
    stock_visto INTEGER NOT NULL CHECK (stock_visto >= 0),
    disponible INTEGER NOT NULL CHECK (disponible IN (0, 1)),
    eliminado INTEGER NOT NULL CHECK (eliminado IN (0, 1)),
    fecha_de_copia TEXT NOT NULL
) STRICT;

-- 3. Tabla de cabecera de borradores de pedidos locales
CREATE TABLE pedido_borrador (
    id_local TEXT PRIMARY KEY,
    usuario TEXT NOT NULL,
    forma_pago TEXT NOT NULL CHECK (forma_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA')),
    fecha TEXT NOT NULL
) STRICT;

-- 4. Tabla de detalle de ítems de cada pedido borrador
CREATE TABLE item_borrador (
    id_local TEXT NOT NULL,
    producto_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_centavos_visto INTEGER NOT NULL CHECK (precio_centavos_visto >= 0),
    PRIMARY KEY (id_local, producto_id),
    FOREIGN KEY (id_local) REFERENCES pedido_borrador(id_local) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES producto_cache(id)
) STRICT;

-- 5. Cola de sincronización de borradores hacia el servidor
CREATE TABLE cola_sync (
    solicitud_uuid TEXT PRIMARY KEY,
    id_local TEXT NOT NULL,
    estado TEXT NOT NULL CHECK (estado IN ('PENDIENTE', 'CONFLICTO', 'RECHAZADO', 'SIMULADO_APROBADO')),
    motivo TEXT,
    FOREIGN KEY (id_local) REFERENCES pedido_borrador(id_local) ON DELETE CASCADE
) STRICT;
