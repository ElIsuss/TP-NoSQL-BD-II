# Checklist de traspaso para completar el TP

## Objetivo

Completar el trabajo práctico de Unidad 7 sobre Food Store, usando el enunciado PDF como fuente de requisitos y el estado actual del repositorio como punto de partida. El agente que reciba esta checklist debe implementar lo pendiente, ejecutar las consultas en MongoDB y PostgreSQL cuando tenga acceso a las bases, y dejar evidencias verificables. No debe inventar resultados, capturas, fuentes de datos ni afirmaciones atribuidas a una IA.

## Checklist para el agente

### 1. Revisar el estado y la procedencia de los datos

- [x] Leer el enunciado completo y revisar `README.md`, `consultas_mongodb.js` y `consultas_postgresql.sql`. (Contexto general: prerrequisito de todas las consignas, en especial Consignas 1 a 7)
- [x] Confirmar en la base real `foodstore` que los pedidos seleccionados y sus detalles son los del origen. (Alcance sugerido de la Consigna 2)
- [x] Verificar IDs, fechas, formas de pago, estados, cliente, líneas, cantidades y precios para los cinco pedidos activos. (Consignas 2 y 5)
- [x] Corregir afirmaciones del README que no estaban respaldadas y describir claramente el alcance de las pruebas. (Entrega)
- [x] Ejecutar consultas PostgreSQL de solo lectura en `foodstore`; registrar evidencia sin datos personales. (Consignas 4 y 5)

### 2. Completar y ejecutar las consultas MongoDB

- [x] Completar el script existente `consultas_mongodb.js` con las cuatro consultas requeridas: (Consigna 4)
  - [x] Listar todos los pedidos mostrando identificador y estado. (Resuelve la Consigna 4.a)
  - [x] Filtrar por un estado que exista en los documentos. (Resuelve la Consigna 4.b)
  - [x] Buscar pedidos que contengan un producto específico dentro de `productos`. (Resuelve la Consigna 4.c)
  - [x] Buscar pedidos cuyo total supere un umbral elegido y justificar ese umbral. (Resuelve la Consigna 4.d)
- [x] Calcular el total a partir de cantidades y precios históricos de las líneas, salvo que el modelo ya almacene un total validado. (Consigna 4.d: base de cálculo del total)
- [x] Ejecutar las consultas contra los cinco pedidos reales exportados en MongoDB 9.0.4 temporal y guardar la salida en `evidencias/evidencia_mongodb.txt`. (Consigna 4)

### 3. Resolver y contrastar en PostgreSQL

- [x] Preparar el archivo adjunto de consultas PostgreSQL en formato `.sql` (puede renombrarse o reemplazar al `.md` actual si corresponde), con las consultas equivalentes a estado y producto. (Consigna 5 y Entrega: adjuntar `consultas_postgresql.sql`)
- [x] Ejecutar las consultas equivalentes en la base original `foodstore` con conexión de solo lectura. (Consigna 5)
- [x] Comparar resultados de fuente: estado devuelve IDs 1–5, producto 3485 devuelve ID 1 y total > $250.000 devuelve ID 4 en ambos motores. (Consigna 5)
- [x] Incorporar en README la tabla comparativa de cantidades e IDs. (Consigna 5)
- [x] Documentar los resultados y que no se observaron diferencias en las consultas comparadas. (Consigna 5)
- [x] Guardar salidas PostgreSQL sin PII y MongoDB en `evidencias/`. (Consigna 5 y Entrega)

### 4. Completar la evaluación de tecnología e IA

- [x] Registrar en `explicacion.md` el prompt de comparación de IA, con modelo actual, lecturas completas y coherencia de datos. (Consigna 6)
- [x] Contrastar dos afirmaciones de la respuesta de IA con documentación oficial de MongoDB y PostgreSQL. (Consigna 7)
- [x] Guardar las fuentes oficiales y los resultados reproducibles de laboratorio. (Consigna 7)
- [x] Escribir una conclusión menor a 200 palabras con criterios de integridad y patrón de lectura. (Consigna 7)

### 5. Preparar y verificar la entrega

- [x] Actualizar `README.md` con el modelo, las consultas, los resultados comparados y el tratamiento de datos personales. (Entrega)
- [x] Generar el PDF final de tres páginas con modelo, resultados, tabla comparativa, contraste de IA y conclusión. (Entrega: PDF único de hasta cinco páginas)
- [x] Incluir los integrantes proporcionados: Juan Martinez e Isaias Morinigo. (Entrega)
- [x] Adjuntar `consultas_mongodb.js` y `consultas_postgresql.sql`. (Entrega)
- [x] Verificar extracción de texto, límite de páginas y consistencia del PDF con scripts y evidencias de la base real. (Entrega: presentación, claridad y evidencias completas)

## Notas y criterios de aceptación

- El enunciado requiere al menos cinco pedidos con líneas y datos esenciales del cliente; no requiere migrar toda la base ni instalar Redis/Neo4j o configurar un clúster. (Consigna 2 y Alcance sugerido)
- Mantener los identificadores, estados, cantidades e importes del origen. Aclarar la procedencia si se usaron registros de prueba. (Alcance sugerido y Consigna 2)
- La comparación entre motores debe usar el mismo subconjunto y los mismos criterios de filtro. (Consigna 5)
- No incluir credenciales ni datos personales reales en la entrega; el usuario MongoDB está anonimizado y las evidencias PostgreSQL omiten nombres y contactos. (Entrega)
- Mantener los archivos adjuntos y el PDF consistentes con el esquema documental implementado. (Consignas 1 y 2, y Entrega)
