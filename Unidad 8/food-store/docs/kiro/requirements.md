# Requisitos del Sistema Móvil Food Store (EARS)

## Contexto y Alcance
La tablet del food truck opera offline en la feria. Puede consultar su catálogo cacheado localmente y armar borradores de pedidos. Al sincronizar con PostgreSQL (servidor central), el servidor valida la solicitud evaluando stock, vigencia del producto y concordancia de precios.

---

### REQ-01: Detección de conflicto por variación de precios
- **EARS**: **WHEN** el precio actual en el servidor es distinto del precio visto registrado en el borrador de la tablet, **THE SYSTEM SHALL** marcar la solicitud en `cola_sync` con estado `'CONFLICTO'` y detallar la diferencia en el motivo.
- **Caso de prueba asociado**: **C2** (Se incrementa el precio en el servidor; la solicitud pasa a `CONFLICTO`. Tras aceptar el nuevo precio, una nueva solicitud resulta en `SIMULADO_APROBADO`).

---

### REQ-02: Rechazo por stock insuficiente
- **EARS**: **WHEN** la cantidad solicitada de un producto en el borrador supera el stock actual disponible en el servidor, **THE SYSTEM SHALL** marcar la solicitud en `cola_sync` con estado `'RECHAZADO'` indicando stock insuficiente.
- **Caso de prueba asociado**: **C3** (Borrador que pide más unidades de las disponibles en el inventario del servidor).

---

### REQ-03: Rechazo por baja lógica de producto
- **EARS**: **WHEN** uno de los productos incluidos en el borrador se encuentra dado de baja lógica (`eliminado = 1` o `disponible = 0`) o no existe en el servidor, **THE SYSTEM SHALL** marcar la solicitud en `cola_sync` con estado `'RECHAZADO'`.
- **Caso de prueba asociado**: **C4** (Producto dado de baja lógica en el servidor; la solicitud es rechazada y al recargar el catálogo local ya no aparece disponible).

---

### REQ-04: Idempotencia en el reenvío de solicitudes
- **EARS**: **WHEN** la tablet reenvía una solicitud con un `solicitud_uuid` ya procesado o existente en `cola_sync`, **THE SYSTEM SHALL** rechazar la inserción por duplicidad de clave primaria sin reevaluar ni duplicar el registro.
- **Caso de prueba asociado**: **C6** (Reintento de sincronización con el mismo identificador UUID; el semáforo solo evalúa solicitudes en estado `'PENDIENTE'`).

