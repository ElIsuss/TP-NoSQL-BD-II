# Consigna 3 — Integrar y Revisar

---

## 3.a Mapa de la Capa de Datos (Arquitectura Multi-Motor)

El sistema Food Store implementa una arquitectura híbrida con tres motores de base de datos especializados. La siguiente tabla y diagrama definen qué información almacena cada motor y la jerarquía de autoridad sobre cada dato:

### Tabla Comparativa de Responsabilidades y Autoridad

| Motor de Base de Datos | Rol en la Arquitectura | Qué datos almacena | Quién manda sobre cada dato (Autoridad) |
| :--- | :--- | :--- | :--- |
| **PostgreSQL 16+** | **Servidor Central (OLTP Autoritative)** | • Catálogo oficial de productos (`producto`, `categoria`).<br>• Lista de precios vigentes y costos.<br>• Inventario y stock físico real.<br>• Clientes, domicilios y medios de pago.<br>• Pedidos confirmados y facturación (`pedido`, `detalle_pedido`).<br>• Auditoría y lógica transaccional ACID. | **Autoridad Máxima Absoluta (Única Fuente de Verdad)**.<br>PostgreSQL decide si hay stock, valida los precios oficiales y confirma o rechaza las ventas. Ningún otro motor puede forzar una venta o modificar el stock central. |
| **MongoDB 9.0+** *(Unidad 7)* | **Proyección Documental de Lectura (Read Model / Analytics)** | • Documentos desnormalizados de pedidos (`pedidos`).<br>• Líneas de productos embebidas con precios unitarios históricos.<br>• Resumen anonimizado de clientes.<br>• Historial de pedidos cerrados para consulta rápida de clientes y tableros analíticos. | **Manda sobre el caché de lectura documental y consultas analíticas**.<br>No tiene autoridad transaccional de escritura original. Sus datos son una proyección derivada de PostgreSQL para evitar sobrecargar el motor relacional con consultas complejas de lectura. |
| **SQLite 3.37+** *(Unidad 8)* | **Base Embebida Móvil Offline (Tablet Food Truck)** | • Caché local de productos disponibles (`producto_cache`).<br>• Borradores de pedidos locales (`pedido_borrador`).<br>• Detalle de ítems del borrador (`item_borrador`).<br>• Cola de sincronización e idempotencia (`cola_sync`).<br>• Instantánea del servidor (`snapshot_servidor`). | **Manda únicamente sobre la interfaz del operador y el armado de borradores locales**.<br>No tiene autoridad sobre precios, stock ni confirmación de ventas (*"El móvil propone, el servidor dispone"*). Sus aprobaciones locales son preliminares (`SIMULADO_APROBADO`). |

### Flujo de Datos entre Motores
```text
           [ PostgreSQL (Servidor Central) ]
             ▲               │               │
             │ (Valida       │ (Exporta      │ (Replica /
             │  Borradores)  │  Snapshot)    │  Sincroniza)
             │               ▼               ▼
      [ SQLite (Tablet) ]             [ MongoDB (U7) ]
      (Borradores Offline)          (Lecturas y Analítica)
```

---

## 3.b Plan de Mantenimiento y Resiliencia (Agregado al Plan de Unidad 6)

Complementando el plan de contingencia y automatización de la Unidad 6 (`SPEC_U6.md`), se definen las políticas operativas relativas al entorno distribuido móvil:

### 1. ¿Qué se respalda y cómo se prueba la restauración?
- **Qué se respalda**:
  - *PostgreSQL*: Respaldo diario completo de la base central `foodstore` mediante `pg_dump -Fc` con rotación automatizada, incluyendo esquema, datos transaccionales, auditoría y vistas de integración (`v_snapshot_movil`).
  - *SQLite (Tablets)*: Las bases SQLite en las tablets son terminales de caché descartable y no requieren respaldo permanente centralizado. No obstante, al cierre de turno, se respalda localmente el archivo `foodstore_movil.db` si existieran transacciones pendientes de sincronización por caída prolongada de red.
- **Cómo se prueba la restauración**:
  - Conforme a la regla de seguridad de Unidad 6, semanalmente se ejecuta una restauración de prueba en una base aislada descartable (`foodstore_restore_test`) usando `pg_restore --no-owner --no-privileges`.
  - Se ejecutan pruebas de verificación que comprueban: cardinalidad de pedidos, integridad de claves foráneas y la correcta generación de `servidor_snapshot.csv` desde `v_snapshot_movil`.

### 2. Si se restaura un respaldo viejo de PostgreSQL, ¿qué hacen las tablets?
- **Impacto**: Si PostgreSQL debe restaurarse a un punto del tiempo anterior (por ejemplo, perdiendo las últimas 8 horas por desastre en el datacenter), la base central desconocerá pedidos o cambios de precio/stock ocurridos en ese lapso.
- **Protocolo de acción en las tablets**:
  1. **Invalidación de caché inmediata**: Al detectar un número de secuencia o fecha de instantánea inconsistente (la fecha de copia de `producto_cache` resulta posterior al timestamp de la base restaurada), la tablet bloquea el envío de nuevos borradores.
  2. **Refresco forzado**: La tablet descarga una nueva instantánea fresca (`v_snapshot_movil`) y recarga `producto_cache`.
  3. **Reconciliación de cola**: Las solicitudes en `cola_sync` emitidas durante la ventana de tiempo afectada se re-evalúan mediante el semáforo contra el servidor restaurado. Si algún producto sufrió variación o falta de stock, la solicitud pasa a `CONFLICTO` o `RECHAZADO`, impidiendo cualquier duplicación o inconsistencia contable.

### 3. ¿Cada cuánto y quién revisa las solicitudes en CONFLICTO o RECHAZADO?
- **Frecuencia**: Al cierre de cada turno de feria (aproximadamente cada 4 horas) y una revisión general diaria consolidada.
- **Responsables**:
  - **Encargado de Caja / Supervisor del Food Truck**: Revisa los motivos operativos y comerciales de cada `CONFLICTO` (ej. si el cliente acepta un nuevo precio o si se cancela el borrador) y `RECHAZADO` por falta de stock para ofrecer productos sustitutos.
  - **DBA / Administrador de Datos**: Revisa los rechazos debidos a fallas técnicas, anomalías en claves o discrepancias de catálogos para asegurar la salud de los servicios de sincronización.

---

## 3.c Code Review con IA sobre los Scripts de la Cursada

Se realizó un proceso de revisión de código asistido por IA (agente Plan) sobre los scripts implementados a lo largo de las distintas unidades del proyecto Food Store.

### Tabla de Hallazgos y Decisiones

| ID | Unidad / Script | Hallazgo / Sugerencia de la IA | Decisión | Motivo y Justificación Técnica |
| :---: | :--- | :--- | :---: | :--- |
| **H-01** | **Unidad 7**<br>`consultas_postgresql.sql` | Sugirió añadir un índice compuesto `(id_pedido, eliminado)` sobre la tabla `detalle_pedido` para acelerar el cálculo de totales y filtros por producto. | **Aceptado / Corregido** | En `foodstore`, las consultas de agregación y joins filtran recurrentemente por `eliminado IS FALSE`. El índice compuesto reduce el costo de escaneo secuencial en tablas de detalle con alta volumetría. |
| **H-02** | **Unidad 7**<br>`consultas_mongodb.js` | Sugirió desnormalizar y almacenar un campo precalculado `total` directamente en la raíz de cada documento de `pedidos` en MongoDB para evitar agregaciones de suma de líneas. | **Descartado con fundamento** | **Descartado**: En el modelo de negocio de Food Store, PostgreSQL es la autoridad sobre los importes. Desnormalizar el total en MongoDB introduce redundancia propensa a inconsistencias si se ajustan líneas o descuentos. En la base se verificó que la agregación sobre las 17 líneas de prueba toma menos de 1 ms, no justificando el riesgo de datos desincronizados. |
| **H-03** | **Unidad 8**<br>`movil/schema_sqlite.sql` | Sugirió agregar la cláusula `ON DELETE CASCADE` en las claves foráneas de `item_borrador` y `cola_sync` vinculadas a `pedido_borrador(id_local)`. | **Aceptado / Corregido** | Si el operador de la tablet cancela o descarta un borrador local antes de sincronizarlo, la cascada asegura que se limpien automáticamente sus ítems y su registro en la cola de sincronización, evitando registros huérfanos. |

### Comprobación en Base de Datos de los Hallazgos Desarrollados

1. **Comprobación de H-01 (Unidad 7 - PostgreSQL)**:
   Se evaluó el plan de ejecución `EXPLAIN ANALYZE` en PostgreSQL para la consulta 5.d (`SUM(dp.cantidad * dp.precio_unitario)`):
   ```sql
   EXPLAIN ANALYZE
   SELECT p.id_pedido, SUM(dp.cantidad * dp.precio_unitario)
   FROM pedido p JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
   WHERE p.id_pedido IN (1,2,3,4,5) AND p.eliminado IS FALSE AND dp.eliminado IS FALSE
   GROUP BY p.id_pedido;
   ```
   *Resultado*: Con el índice en `detalle_pedido(id_pedido, eliminado)`, la búsqueda se realiza mediante *Index Scan*, eliminando el filtrado residual de filas inactivas y reduciendo los accesos a disco.

2. **Comprobación de H-02 (Unidad 7 - MongoDB - Hallazgo Descartado)**:
   Se probó la consulta de agregación calculando el total al vuelo en MongoDB:
   ```javascript
   db.pedidos.aggregate([
     { $match: { id_pedido: { $in: [1, 2, 3, 4, 5] } } },
     { $unwind: "$productos" },
     { $group: { _id: "$id_pedido", total: { $sum: { $multiply: ["$productos.cantidad", "$productos.precio_unitario"] } } } },
     { $match: { total: { $gt: 250000 } } }
   ]);
   ```
   *Resultado*: La consulta arrojó idéntico resultado que PostgreSQL (Pedido 4 con \$302.935,07) con un tiempo de ejecución despreciable, confirmando que la desnormalización del total era innecesaria y riesgosa para la integridad.

3. **Comprobación de H-03 (Unidad 8 - SQLite)**:
   Se probó la eliminación de un borrador en `foodstore_movil.db` con `PRAGMA foreign_keys = ON;`:
   ```sql
   DELETE FROM pedido_borrador WHERE id_local = 'b1111111-1111-1111-1111-111111111111';
   SELECT COUNT(*) FROM item_borrador WHERE id_local = 'b1111111-1111-1111-1111-111111111111';
   SELECT COUNT(*) FROM cola_sync WHERE id_local = 'b1111111-1111-1111-1111-111111111111';
   ```
   *Resultado*: Ambas consultas devolvieron exactamente `0`, demostrando que la cascada preserva la higiene de la base local sin requerir scripts manuales de limpieza.

