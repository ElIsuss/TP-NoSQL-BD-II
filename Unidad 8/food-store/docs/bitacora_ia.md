# Bitácora de Uso de Inteligencia Artificial (IA)

**Asignatura**: Base de Datos II · Tecnicatura Universitaria en Programación (UTN)  
**Proyecto**: Food Store — Trabajo Práctico N.º 8: La base de la tablet y el cierre de la capa de datos  
**Integrantes**: Juan Martinez, Isaias Morinigo  

---

## Entrada 1: Definición del Esquema Relacional SQLite Móvil (Consigna 1.b)

- **Qué se le pidió a la IA**:
  Diseñar el esquema DDL para la tablet en SQLite con las cuatro tablas requeridas (`producto_cache`, `pedido_borrador`, `item_borrador`, `cola_sync`), aplicando restricciones de integridad.
- **Qué se aceptó**:
  - Declaración obligatoria de `PRAGMA foreign_keys = ON;`.
  - Creación de tablas en modo `STRICT` (SQLite 3.37+) para garantizar tipado estricto de columnas.
  - Almacenamiento de importes monetarios como enteros en centavos (`precio_centavos`) para evitar desfasajes por redondeo de coma flotante.
  - Restricciones `CHECK` para estados válidos y formas de pago (`EFECTIVO`, `TARJETA`, `TRANSFERENCIA`).
- **Qué se descartó y por qué**:
  - La IA propuso inicialmente usar tipos `REAL`/`FLOAT` para los precios y números secuenciales simples (`INTEGER AUTOINCREMENT`) para los pedidos del móvil.
  - *Motivo del descarte*: El enunciado exige precios estrictamente en centavos y el uso de `UUID` en `id_local` y `solicitud_uuid` para prevenir colisiones en ambientes distribuidos desconectados.

---

## Entrada 2: Lógica y Jerarquía del Semáforo de Sincronización (Consigna 2.b)

- **Qué se le pidió a la IA**:
  Generar la consulta SQL que evalúe las solicitudes en cola de sincronización contra la instantánea del servidor (`snapshot_servidor`), asignando los estados del semáforo.
- **Qué se aceptó**:
  - Estructuración mediante Common Table Expressions (CTE) calculando banderas booleanas por ítem y agregando con `SUM(...) > 0` para determinar el estado de la solicitud.
  - Priorización estricta: Rojo (`RECHAZADO`) prevalece sobre Amarillo (`CONFLICTO`), y solo si todo coincide se otorga Verde (`SIMULADO_APROBADO`).
  - Filtrado excluyente `WHERE estado = 'PENDIENTE'` para respetar el principio de idempotencia.
- **Qué se descartó y por qué**:
  - La IA sugirió incluir sentencias `UPDATE` sobre el stock de `snapshot_servidor` al aprobar una solicitud, restando las cantidades vendidas.
  - *Motivo del descarte*: Viola una de las reglas cardinales del trabajo práctico: *"La tablet nunca cambia el stock ni el precio del servidor, ni confirma ventas: SIMULADO_APROBADO no es una venta"*. El móvil propone y simula, pero jamás altera los datos del servidor.

---

## Entrada 3: Code Review y Optimización en MongoDB (Consigna 3.c)

- **Qué se le pidió a la IA**:
  Analizar los scripts de la cursada (PostgreSQL, MongoDB y SQLite) en busca de optimizaciones de rendimiento y mejoras de integridad.
- **Qué se aceptó**:
  - Creación de índice compuesto `(id_pedido, eliminado)` en PostgreSQL (`detalle_pedido`) y eliminación en cascada (`ON DELETE CASCADE`) en los borradores locales de SQLite.
- **Qué se descartó y por qué**:
  - La IA propuso desnormalizar un campo precalculado `total` directamente en la raíz de cada documento de la colección `pedidos` en MongoDB para prescindir de la etapa de agregación con `$unwind` y `$group`.
  - *Motivo del descarte*: En la arquitectura de Food Store, PostgreSQL es la autoridad sobre los importes facturados. Desnormalizar totales en el modelo documental introduce riesgo de discrepancias si se modifican o anulan líneas. Además, se comprobó en laboratorio que la agregación sobre las 17 líneas de prueba se ejecuta en menos de 1 ms, haciendo innecesaria la desnormalización.

