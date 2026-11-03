# Diseño de la Capa de Datos Móvil — Food Store

## 1. Principio Arquitectónico
> **"El móvil propone, el servidor dispone."**
La tablet en el food truck no tiene autoridad para alterar el stock, cambiar precios ni confirmar ventas en PostgreSQL. El móvil únicamente consulta su copia local (`producto_cache`) y genera intenciones de compra (`pedido_borrador`, `item_borrador`, `cola_sync`).
El estado `SIMULADO_APROBADO` en el entorno de simulación representa una validación preliminar positiva, **no una venta confirmada**.

## 2. Esquema Relacional SQLite (Modo STRICT)
Para asegurar consistencia de tipos estricta y cumplir con SQLite 3.37+, todas las tablas se definen con `STRICT` y se activa `PRAGMA foreign_keys = ON;`.

- **`producto_cache`**: Almacena la instantánea del catálogo obtenida del servidor.
  - Precios representados en centavos (`INTEGER`) para evitar imprecisiones de coma flotante.
  - Banderas `disponible` y `eliminado` restringidas a `0` o `1`.
- **`pedido_borrador`**: Cabecera del pedido local.
  - Identificador UUID (`TEXT`).
  - Restricción en `forma_pago` a valores permitidos: `'EFECTIVO'`, `'TARJETA'`, `'TRANSFERENCIA'`.
- **`item_borrador`**: Detalle de los ítems del borrador.
  - Claves foráneas vinculadas a `pedido_borrador` y `producto_cache`.
  - Validación `CHECK (cantidad > 0)`.
- **`cola_sync`**: Cola de sincronización e idempotencia.
  - `solicitud_uuid` como clave primaria para evitar duplicaciones.
  - Máquina de estados: `'PENDIENTE'`, `'CONFLICTO'`, `'RECHAZADO'`, `'SIMULADO_APROBADO'`.

## 3. Máquina de Estados del Semáforo
Al procesar las solicitudes en estado `'PENDIENTE'`:
1. **Prioridad 1 (Rojo - RECHAZADO)**: Se evalúa si algún producto no existe, fue eliminado, no está disponible o el stock actual en el servidor es menor a la cantidad solicitada.
2. **Prioridad 2 (Amarillo - CONFLICTO)**: Si no hay causal de rechazo, pero el `precio_centavos_visto` difiere del precio actual del servidor.
3. **Prioridad 3 (Verde - SIMULADO_APROBADO)**: Si todas las líneas existen, tienen stock suficiente y los precios coinciden exactamente.

