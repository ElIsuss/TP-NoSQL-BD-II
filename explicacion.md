# Comparación de PostgreSQL y MongoDB con apoyo de IA

## Prompt utilizado

> Compará PostgreSQL con MongoDB para Food Store. El modelo actual es relacional y separa `pedido`, `detalle_pedido`, `cliente` y `producto`. Se consulta con frecuencia cada pedido completo (cabecera, cliente y líneas). Hay que conservar la coherencia de las cantidades y los precios históricos. Explicá ventajas y riesgos de cada alternativa y recomendá mantener PostgreSQL, usar MongoDB para este subconjunto o combinar ambos, justificando con criterios técnicos.

La siguiente respuesta es una síntesis generada por el asistente de IA utilizado durante la elaboración de este informe, no una transcripción extensa:

1. PostgreSQL encaja con el modelo relacional y permite expresar integridad con claves y restricciones; es apropiado para conservar consistencia entre pedidos, detalles y productos.
2. MongoDB puede representar un pedido completo como documento con cliente y líneas embebidos, haciendo posible leer datos relacionados en una sola operación. Las líneas contenidas en un mismo documento también permiten actualizaciones atómicas del documento.
3. Recomendación: mantener PostgreSQL como fuente autoritativa. Considerar MongoDB como proyección de lectura solo si la lectura de pedidos completos es frecuente y el beneficio justifica sincronizar datos duplicados; mantener cantidades y precios históricos en cada línea.

## Contraste de dos afirmaciones

| Afirmación de IA | Contraste | Resultado |
|---|---|---|
| El embedding permite recuperar datos relacionados en una operación y es adecuado cuando los hijos se consultan dentro del contexto del padre. | La documentación oficial de MongoDB describe documentos embebidos como un modelo que permite consultar datos relacionados en una operación y recomienda embedding para relaciones uno-a-muchos cuando los hijos se ven en contexto del padre. | Respaldada. El documento `pedido` con `cliente` y `productos` es coherente con ese patrón. |
| PostgreSQL puede mantener reglas de integridad mediante restricciones declarativas. | La documentación oficial de PostgreSQL describe `CHECK`, `UNIQUE`, claves primarias y foráneas, que pueden expresar reglas de valores, unicidad e integridad referencial. | Respaldada. El esquema de demostración incluye `CHECK (cantidad > 0)`, `CHECK (precio_unitario >= 0)`, claves foráneas y `UNIQUE (id_pedido, id_producto)`. |

## Resultados del laboratorio

Las consultas se ejecutaron en MongoDB 9.0.4 temporal con una migración de datos de la base real `foodstore`, y en PostgreSQL local con conexión de solo lectura. Se verificaron los cinco pedidos activos con IDs 1–5 y sus 17 líneas. Ambos motores devolvieron los pedidos 1–5 para estado `PENDIENTE`, el pedido 1 para el producto 3485 y el pedido 4 para el total mayor a $250.000 ($302.935,07). Los resultados sin datos personales están en `evidencias/evidencia_mongodb.txt` y `evidencias/evidencia_postgresql.txt`.

Un cotejo automático campo por campo confirmó coincidencia exacta entre PostgreSQL y MongoDB en los cinco encabezados y las 17 líneas, incluidos IDs, fechas originales, formas de pago, estados, IDs de cliente, productos, cantidades y precios. Las etiquetas de cliente se anonimizaron y no se copiaron nombres, correos ni teléfonos. BSON Date guarda milisegundos; para conservar la precisión original de microsegundos se incluyó además el timestamp PostgreSQL como `fecha_hora_origen`. El resumen del cotejo está en `evidencias/comparacion_integridad.txt`.

## Conclusión (menos de 200 palabras)

Conviene mantener PostgreSQL como fuente autoritativa de pedidos. El modelo relaciona pedidos, clientes, productos y detalles, y las cantidades/precios deben conservar coherencia: claves foráneas y restricciones `CHECK`/`UNIQUE` ofrecen controles directos. MongoDB permite reunir cliente y líneas en un documento, simplificando la lectura frecuente del pedido completo; el embedding también permite actualizar atómicamente el documento. Sin embargo, duplicar datos entre motores agrega sincronización y riesgo de divergencia. En esta prueba, las consultas de estado, producto y total devolvieron los mismos IDs sobre los cinco pedidos reales seleccionados. Recomiendo PostgreSQL como sistema de registro y MongoDB como proyección de lectura solo si una necesidad medida justifica el costo de sincronización; la migración debe mantener los precios históricos y anonimizar los datos personales en la entrega.

## Fuentes

- MongoDB Manual, “Embedded Data Models”: https://www.mongodb.com/docs/manual/data-modeling/embedding/
- PostgreSQL Documentation, “Constraints”: https://www.postgresql.org/docs/current/ddl-constraints.html
