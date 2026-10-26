# TP Unidad 7: NoSQL y nuevas formas de almacenamiento
## Parte 1 — Migración de pedidos de PostgreSQL a MongoDB

### 1. Identificación de tablas y diseño documental

En PostgreSQL se identificaron las tablas `pedido`, `detalle_pedido`, `cliente` y `producto`, junto con sus claves primarias y foráneas.

Para MongoDB se propuso una colección llamada `pedidos`. Cada documento conserva el identificador original del pedido, la fecha, la forma de pago, el estado, los datos esenciales del cliente y un arreglo con los productos comprados.

Se eligió incrustar los datos del cliente y los detalles dentro del pedido para consultar toda la información relacionada en una sola lectura. Se conserva el precio unitario histórico de cada producto para no perder el valor registrado al momento de la compra.

### 2. Migración y verificación

Se migraron cinco pedidos de PostgreSQL a MongoDB, conservando los identificadores originales y los datos principales de cada operación.

La verificación en MongoDB confirmó la existencia de cinco documentos y diez detalles de productos en total. También se comprobaron las fechas, las formas de pago, los estados y los datos esenciales de los clientes.

Las fechas se muestran en UTC en MongoDB, lo que representa el mismo instante que la fecha original con su zona horaria.

### 3. Reglas de integridad

**Regla 1: integridad referencial.** Cada pedido debe corresponder a un cliente válido y cada detalle debe referenciar un pedido y un producto existentes en PostgreSQL. Durante la migración se conservaron los identificadores originales para mantener estas relaciones. MongoDB no aplica automáticamente las claves foráneas de PostgreSQL, por lo que estas relaciones deben controlarse mediante validaciones adicionales.

**Regla 2: integridad de los detalles.** La cantidad de cada producto debe ser mayor que cero y el precio unitario debe ser mayor o igual que cero. Además, PostgreSQL impide repetir un mismo producto en dos detalles del mismo pedido mediante la restricción `UNIQUE (id_pedido, id_producto)`. Estas condiciones deben conservarse y validarse en MongoDB o en la aplicación.

### Justificación del diseño

La estructura documental agrupa la información que normalmente se obtiene mediante uniones entre pedidos, clientes, detalles y productos. Esto simplifica la lectura de un pedido completo. Asimismo, almacenar el precio histórico en cada detalle permite preservar el importe registrado en la compra, independientemente de futuros cambios en el precio actual del producto.
