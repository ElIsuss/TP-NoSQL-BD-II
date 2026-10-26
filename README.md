# TP Unidad 7: NoSQL y nuevas formas de almacenamiento

## Modelo y alcance

El modelo relacional de `foodstore` usa `pedido`, `detalle_pedido`, `cliente` y `producto`. En MongoDB cada documento de `pedidos` conserva el ID del pedido, fecha, forma de pago y estado; embebe el ID de cliente y una etiqueta anonimizada, además de un arreglo `productos` con IDs de detalle/producto, nombre, cantidad y precio unitario histórico. No se exportan nombres reales, correos ni teléfonos. BSON Date tiene precisión de milisegundos; `fecha_hora_origen` conserva el timestamp PostgreSQL exacto, incluidas sus seis cifras de microsegundos.

Se migraron y verificaron contra la base local `foodstore` los cinco pedidos activos de IDs 1–5, con 17 líneas. Sus IDs, fechas, formas de pago, estados, IDs de cliente y líneas (producto, cantidad y precio histórico) coinciden con PostgreSQL. Las etiquetas de cliente en MongoDB son deliberadamente anonimizadas.

## Reglas de integridad

1. Mantener la relación pedido-cliente y las referencias de cada línea a su pedido y producto. En MongoDB estas referencias deben validarse desde la aplicación o mediante controles adecuados.
2. La cantidad debe ser mayor que cero, el precio no negativo y no debe repetirse el mismo producto en un pedido. PostgreSQL puede proteger estas condiciones con `CHECK`, `FOREIGN KEY` y `UNIQUE`; deben preservarse al migrar.

## Consultas y verificación

`consultas_mongodb.js` carga los documentos en `food_store_nosql` mediante upsert para poder repetirlo sin borrar la colección y ejecuta las consultas de listado, estado, producto y total mayor a $250.000. Se ejecutó contra una instancia MongoDB temporal local; la salida está en `evidencias/evidencia_mongodb.txt`.

Las consultas equivalentes están en `consultas_postgresql.sql` y se ejecutaron en la base `foodstore` con una conexión de solo lectura. Un cotejo automático campo por campo confirmó coincidencia exacta de cabeceras, timestamps originales, IDs de clientes, líneas, cantidades y precios históricos entre PostgreSQL y MongoDB. La evidencia omite datos personales de clientes y está en `evidencias/evidencia_postgresql.txt`, `evidencias/evidencia_mongodb.txt` y `evidencias/comparacion_integridad.txt`.

| Filtro | PostgreSQL (`foodstore`) | MongoDB | IDs coinciden |
|---|---:|---:|---|
| Estado `PENDIENTE` | 5: 1, 2, 3, 4, 5 | 5: 1, 2, 3, 4, 5 | Sí |
| Producto `3485` | 1: 1 | 1: 1 | Sí |
| Total mayor a `$250.000` | 1: 4 ($302.935,07) | 1: 4 ($302.935,07) | Sí |

El umbral de `$250.000` selecciona el pedido 4: es el único de estos cinco que supera el umbral. La suma usa cantidad por precio histórico. No se detectaron diferencias entre los resultados de PostgreSQL y MongoDB.

## Comparación de tecnologías e IA

La comparación generada con IA, el prompt utilizado, la validación de dos afirmaciones con documentación oficial y la recomendación técnica están en `explicacion.md`. La conclusión recomienda conservar PostgreSQL como fuente autoritativa y usar MongoDB como proyección de lectura solo si el acceso frecuente a pedidos completos justifica mantenerla.

## Entrega y pendientes externos

- Informe PDF: `entrega_TP_Unidad7.pdf` (máximo cinco páginas; la consigna original está aparte en `BDII_Unidad7_TP_FoodStore_NoSQL.pdf`).
- Integrantes: Juan Martinez e Isaias Morinigo.
- Scripts adjuntos: `consultas_mongodb.js` y `consultas_postgresql.sql`.
- Evidencias de ejecución: carpeta `evidencias/`.
