-- TP 8 - Consigna 2.a
-- Vista PostgreSQL para exportar la instantanea del catalogo a la tablet.
-- Ejecutar en la base Food Store (PostgreSQL 16+).

-- En el esquema de origen, "activo" indica si el producto esta disponible.
-- No existe una columna separada para distinguir una baja logica; por eso
-- "eliminado" se exporta como FALSE. La vista incluye tambien los inactivos.
CREATE OR REPLACE VIEW v_snapshot_movil AS
SELECT
    p.id_producto AS id,
    p.nombre AS nombre,
    ROUND(p.precio_actual * 100)::INTEGER AS precio_centavos,
    p.stock AS stock,
    p.activo AS disponible,
    FALSE AS eliminado
FROM producto AS p;

COMMENT ON VIEW v_snapshot_movil IS
'Instantanea del catalogo para sincronizacion movil. Exportar a CSV con \copy.';

-- Ejecutar en psql desde la carpeta food-store:
-- \copy (SELECT id, nombre, precio_centavos, stock, disponible, eliminado FROM v_snapshot_movil ORDER BY id) TO 'movil/servidor_snapshot.csv' WITH CSV HEADER
