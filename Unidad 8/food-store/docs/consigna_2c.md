# Consigna 2.c — Resultados de los Casos de Simulación del Semáforo (C2 a C6)

Este documento detalla los comandos, resultados y justificaciones técnicas de cada escenario de prueba ejecutado en la simulación de sincronización móvil offline contra el servidor central.

---

### Caso C2: Conflicto por suba de precio y posterior aceptación

- **Preparación**:
  Borrador inicial con el producto 101 (*Hamburguesa Doble Queso*) a un precio visto de $8.500,00 (`850000` centavos). Posteriormente, en el servidor se actualiza el precio a $9.200,00 (`920000` centavos).
- **Comandos**:
  ```sql
  -- Estado PENDIENTE en solicitud inicial s2222222-aaaa-2222-2222-222222222222
  UPDATE snapshot_servidor SET precio_centavos = 920000 WHERE id = 101;
  -- Ejecución del semáforo
  -- Luego el cliente acepta el precio:
  UPDATE item_borrador SET precio_centavos_visto = 920000 
  WHERE id_local = 'b2222222-2222-2222-2222-222222222222' AND producto_id = 101;
  INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
  VALUES ('s2222222-bbbb-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'PENDIENTE', 'Reintento con nuevo precio');
  ```
- **Resultado obtenido**:
  - `s2222222-aaaa-2222-2222-222222222222`: `CONFLICTO` (*"Cambio de precio en producto 101 (visto: $8500.0, actual: $9200.0)"*).
  - `s2222222-bbbb-2222-2222-222222222222`: `SIMULADO_APROBADO` (*"Todos los productos validados con stock y precios vigentes"*).
- **Explicación**: El semáforo detecta la discrepancia tarifaria entre la caché local y el servidor central, pausando la operación en amarillo sin rechazarla ni forzar la venta. Una vez que el comensal consiente el nuevo importe, se actualiza el borrador y una nueva solicitud con identificador propio resulta aprobada.

---

### Caso C3: Rechazo por stock insuficiente

- **Preparación**:
  Borrador que solicita 100 unidades de *Papas Fritas Medianas* (producto 102), cuando el servidor únicamente posee 40 unidades en inventario.
- **Comandos**:
  ```sql
  INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
  VALUES ('b3333333-3333-3333-3333-333333333333', 102, 100, 350000);
  INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
  VALUES ('s3333333-aaaa-3333-3333-333333333333', 'b3333333-3333-3333-3333-333333333333', 'PENDIENTE', 'Envio borrador C3');
  ```
- **Resultado obtenido**:
  - `s3333333-aaaa-3333-3333-333333333333`: `RECHAZADO` (*"Stock insuficiente para producto 102 (solicitado: 100, stock: 40)"*).
- **Explicación**: La validación de stock tiene prioridad máxima (Rojo); al no disponer de unidades suficientes para satisfacer la orden completa, el semáforo rechaza de inmediato la solicitud para prevenir ventas en descubierto o inconsistencias físicas de stock.

---

### Caso C4: Rechazo por baja lógica y recarga de catálogo

- **Preparación**:
  Borrador con el producto 103 (*Gaseosa 500ml*). En el servidor se realiza una baja lógica marcando `eliminado = 't'` y `disponible = 'f'`.
- **Comandos**:
  ```sql
  UPDATE snapshot_servidor SET eliminado = 't', disponible = 'f' WHERE id = 103;
  -- Ejecución del semáforo
  -- Recarga de catálogo:
  INSERT OR REPLACE INTO producto_cache (id, nombre, precio_centavos, stock_visto, disponible, eliminado, fecha_de_copia)
  SELECT id, nombre, precio_centavos, stock, 
         CASE WHEN disponible = 't' THEN 1 ELSE 0 END,
         CASE WHEN eliminado = 't' THEN 1 ELSE 0 END, datetime('now')
  FROM snapshot_servidor;
  ```
- **Resultado obtenido**:
  - Solicitud: `RECHAZADO` (*"Producto 103 dado de baja lógica"*).
  - Consulta de catálogo offline (`disponible = 1 AND eliminado = 0 AND stock_visto > 0`): el producto 103 queda excluido de la carta visible para el mozo.
  - Consulta en `producto_cache`: la fila del producto 103 persiste con `disponible = 0` y `eliminado = 1`.
- **Explicación**: El servidor rechaza la solicitud porque el producto ya no se comercializa. Al sincronizar la instantánea, la tablet actualiza los estados de la fila existente (lápida / tombstone) preservando la integridad referencial de los borradores históricos sin romper claves foráneas.

---

### Caso C5: Aprobación sin cambios

- **Preparación**:
  Borrador generado con datos plenamente vigentes del producto 3485 (*Empanada Criolla Carne*), solicitando 5 unidades dentro del stock disponible de 100 y a su precio actual.
- **Comandos**:
  ```sql
  INSERT INTO item_borrador (id_local, producto_id, cantidad, precio_centavos_visto)
  VALUES ('b5555555-5555-5555-5555-555555555555', 3485, 5, 460206);
  INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
  VALUES ('s5555555-aaaa-5555-5555-555555555555', 'b5555555-5555-5555-5555-555555555555', 'PENDIENTE', 'Envio borrador C5');
  ```
- **Resultado obtenido**:
  - `s5555555-aaaa-5555-5555-555555555555`: `SIMULADO_APROBADO` (*"Todos los productos validados con stock y precios vigentes"*).
- **Explicación**: Al cumplirse todas las condiciones (producto existente, no eliminado, disponible, stock suficiente y precio sin desfasaje), el semáforo emite luz verde de simulación favorable.

---

### Caso C6: Reenvío de la misma solicitud (Idempotencia)

- **Preparación**:
  Intento de reenviar la misma solicitud `s5555555-aaaa-5555-5555-555555555555` con idéntico UUID.
- **Comando**:
  ```sql
  INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
  VALUES ('s5555555-aaaa-5555-5555-555555555555', 'b5555555-5555-5555-5555-555555555555', 'PENDIENTE', 'Reintento');
  ```
- **Resultado obtenido**:
  - Error en la base: `UNIQUE constraint failed: cola_sync.solicitud_uuid`.
  - Re-ejecución del semáforo: la solicitud previa no sufre alteración alguna porque el filtro `WHERE estado = 'PENDIENTE'` ignora los registros ya resueltos.
- **Explicación e Idempotencia en Producción (Parada 8)**:
  La clave primaria local en `cola_sync` previene registros duplicados en el cliente.
  *¿Dónde iría la protección real en un sistema de verdad?*: En una arquitectura en producción, la protección de idempotencia reside obligatoriamente en el **servidor PostgreSQL**, a través de una tabla de auditoría de transacciones con restricción `UNIQUE (solicitud_uuid)` (o token de idempotencia en la capa de API); ante un reenvío por fallos intermitentes de conectividad en la feria, el servidor detecta el UUID ya procesado, no descuenta stock ni cobra nuevamente, y retorna de forma segura el resultado original previamente computado.

---

### Invarianza en PostgreSQL (Comprobación de Autoridad Central)

Durante toda la ejecución de la simulación del semáforo, el servidor central opera como entidad de solo lectura respecto a la tablet.

Consulta de verificación en PostgreSQL:
```sql
-- Verificar que la cantidad de pedidos y los stocks permanecen invariables
SELECT 
    (SELECT COUNT(*) FROM pedido) AS total_pedidos_servidor,
    (SELECT COUNT(*) FROM detalle_pedido) AS total_detalles_servidor,
    (SELECT SUM(stock) FROM producto) AS stock_total_servidor;
```

**Resultado de invarianza**:
- La cantidad de pedidos en PostgreSQL permanece idéntica (los borradores locales no crean pedidos en el servidor).
- El stock de cada producto en PostgreSQL no sufrió descuento alguno.
- Queda demostrado que `SIMULADO_APROBADO` constituye únicamente una validación de factibilidad y no una venta consumada.

