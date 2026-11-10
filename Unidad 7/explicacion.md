# Comparación práctica: solución documental (MongoDB) vs. relacional (PostgreSQL)

**Unidad 7 · NoSQL y nuevas formas de almacenamiento · Food Store**  
**Integrantes:** Juan Martinez, Isaias Morinigo

---

## 1. Contexto

Se modeló una parte del dominio (pedidos y sus líneas) en MongoDB y se comparó con la solución relacional en PostgreSQL. Se migraron y verificaron los 5 pedidos activos de IDs 1–5 (17 líneas) contra la base local `foodstore`.

## 2. Modelo documental (MongoDB)

Cada documento de la colección `pedidos` conserva:
- `id_pedido`, `fecha_hora` (BSON Date con precisión de ms; `fecha_hora_origen` conserva el timestamp PostgreSQL exacto con microsegundos).
- `forma_pago`, `estado`.
- `id_cliente` y una etiqueta anonimizada.
- Arreglo `productos` con: id de detalle/producto, nombre, cantidad, precio unitario histórico.

Reglas de integridad preservadas por aplicación: relación pedido-cliente, referencias de línea a pedido/producto, cantidad > 0, precio ≥ 0, sin repetir el mismo producto en un pedido.

## 3. Consultas y verificación

`consultas_mongodb.js` carga los documentos en `food_store_nosql` mediante upsert (repetible sin borrar la colección) y ejecuta: listado, filtro por estado, filtro por producto y total mayor a $250.000.

Las consultas equivalentes están en `consultas_postgresql.sql` (conexión de solo lectura). Un cotejo automático campo por campo confirmó coincidencia exacta de cabeceras, timestamps originales, IDs de clientes, líneas, cantidades y precios históricos.

| Filtro | PostgreSQL (`foodstore`) | MongoDB | IDs coinciden |
|---|---:|---:|---|
| Estado `PENDIENTE` | 5: 1, 2, 3, 4, 5 | 5: 1, 2, 3, 4, 5 | Sí |
| Producto `3485` | 1: 1 | 1: 1 | Sí |
| Total mayor a `$250.000` | 1: 4 ($302.935,07) | 1: 4 ($302.935,07) | Sí |

El umbral de `$250.000` selecciona el pedido 4: es el único de los cinco que lo supera. La suma usa cantidad por precio histórico. No se detectaron diferencias.

Evidencias: `evidencias/evidencia_postgresql.txt`, `evidencias/evidencia_mongodb.txt`, `evidencias/comparacion_integridad.txt`.

## 4. Comparación de tecnologías (asistida por IA)

### 4.1 Prompt enviado a la IA

> "Compará PostgreSQL y MongoDB para el dominio de pedidos de Food Store. Considerá integridad referencial, transacciones, consultas de agregación, escalabilidad de lectura y consistencia. Recomendá cuál usar como fuente autoritativa y cuál como proyección."

### 4.2 Respuesta de la IA (resumen)

La IA recomendó conservar PostgreSQL como fuente autoritativa (transacciones ACID, FKs, CHECK) y usar MongoDB como proyección de lectura para consultas frecuentes de pedidos completos, evitando joins. También sugirió desnormalizar un campo `total` precalculado en cada documento para evitar `$unwind` + `$group`.

### 4.3 Validación de afirmaciones con documentación oficial

1. **Afirmación: "PostgreSQL garantiza integridad referencial y transacciones ACID; MongoDB no impone FKs por defecto."**  
   *Validación:* Correcta. PostgreSQL soporta `FOREIGN KEY`, `CHECK`, `UNIQUE`, `NOT NULL` y transacciones ACID nativas. MongoDB delega la integridad a la aplicación (aunque soporta transacciones multi-documento desde 4.0). Se valida contra la documentación oficial de PostgreSQL y MongoDB.

2. **Afirmación: "Desnormalizar el campo `total` en MongoDB acelera las consultas de agregación."**  
   *Validación:* Parcialmente cierta en términos de rendimiento, pero riesgosa. Se verificó en laboratorio que la agregación sobre las 17 líneas de prueba toma menos de 1 ms, por lo que la ganancia es despreciable frente al riesgo de desincronización.

### 4.4 Decisión final (humana)

- **PostgreSQL** es la única fuente autoritativa: catálogo, precios, stock, pedidos, facturación, auditoría.
- **MongoDB** se usa como proyección de lectura (read model) para pedidos cerrados y reportería, derivada de PostgreSQL, sin interferir en el OLTP.
- **Se descarta** la desnormalización del campo `total` en MongoDB (hallazgo H-02): PostgreSQL es la autoridad sobre los importes; duplicar el total introduce riesgo de inconsistencias ante notas de crédito/ajustes; la agregación nativa toma < 1 ms sobre las 17 líneas de prueba.

## 5. Anonimización

No se exportan nombres reales, correos ni teléfonos. Las etiquetas de cliente en MongoDB son deliberadamente anonimizadas. BSON Date tiene precisión de milisegundos; `fecha_hora_origen` conserva el timestamp PostgreSQL exacto (6 cifras de microsegundos).

## 6. Conclusión

La arquitectura desacoplada conserva PostgreSQL como fuente de verdad y MongoDB como proyección de lectura. La comparación práctica (migración de 5 pedidos / 17 líneas) confirmó coincidencia exacta entre ambos motores, validando la viabilidad de la proyección documental sin comprometer la integridad transaccional.
