# Plan de trabajo — TP Unidad 8

## Problema y enfoque

Completar el TP 8 de Base de Datos II sobre el proyecto Food Store: una base SQLite para el uso offline de la tablet, una simulación de sincronización contra PostgreSQL, la integración con MongoDB de la Unidad 7 y los documentos requeridos para revisión, mantenimiento y defensa.

El alcance acordado incluye las consignas 1 a 4 y todos sus entregables. La simulación del semáforo se hará en SQL puro, sin aplicación móvil ni Python. Este chat se usa para planificar; la generación, builds, ejecuciones y validaciones se harán en Antigravity. No se modificarán ni ejecutarán archivos del repositorio desde esta sesión.

## Secuencia de trabajo

1. **Preparar insumos y entorno de prueba**
   - En Antigravity, revisar los scripts de las unidades y el esquema real de `foodstore`; usar una copia aislada con datos inventados.
   - Reutilizar la Unidad 7 para el mapa de motores y el code review.
   - Conseguir el plan de mantenimiento de Unidad 6 y el formato oficial de DUIA, que no aparecen entre los archivos visibles actuales.
   - Confirmar el inventario de scripts que OpenCode deberá revisar.
2. **Especificar antes de generar código**
   - Crear en Kiro `requirements.md` con cuatro requisitos EARS, cada uno vinculado a un caso de prueba.
   - Crear `design.md` y `tasks.md` breves.
   - Revisar que los requisitos cubran las restricciones de la consigna y que los tasks estén listos para OpenCode.
3. **Construir y probar el esquema SQLite**
   - Generar `movil/schema_sqlite.sql` con `PRAGMA foreign_keys = ON;` y las cuatro tablas `STRICT`: `producto_cache`, `pedido_borrador`, `item_borrador` y `cola_sync`.
   - Aplicar restricciones de precio no negativo en centavos, booleanos 0/1, formas de pago permitidas, claves foráneas, cantidades positivas y estados de sincronización permitidos.
   - Generar `movil/pruebas_sqlite.sql`: transacción confirmada y transacción revertida; caso C1 de catálogo local sin conexión; caso C7 para cantidad cero y producto inexistente, comprobando errores y ausencia de filas nuevas.
4. **Preparar instantánea y semáforo**
   - En una copia de pruebas de PostgreSQL, crear `v_snapshot_movil` según el esquema del proyecto y la parada 5 del apunte.
   - Exportar `servidor_snapshot.csv`, importarlo en SQLite como `snapshot_servidor` y cargar `producto_cache`, registrando fecha de copia.
   - Crear `movil/semaforo.sql`: procesar solo solicitudes `PENDIENTE`, con prioridad `RECHAZADO` ante producto inexistente/no disponible/dado de baja/stock insuficiente, después `CONFLICTO` por cambio de precio y, si todo coincide, `SIMULADO_APROBADO`.
   - Mantener PostgreSQL como autoridad; la sincronización no modifica stock, precios ni ventas.
5. **Ejecutar escenarios y reunir evidencia**
   - Preparar C2–C6 en la copia de prueba, exportando instantáneas nuevas cuando corresponda.
   - Comprobar conflicto y aceptación con solicitud nueva (C2), stock insuficiente (C3), baja lógica y recarga de catálogo (C4), aprobación sin cambios (C5), UUID duplicado e idempotencia (C6).
   - Verificar que repetir la simulación no reevalúa solicitudes no pendientes y demostrar al final que no cambiaron cantidad de pedidos ni stock en PostgreSQL.
   - Conservar comandos y resultados sin incluir datos personales.
6. **Integrar documentación y revisión**
   - Preparar el informe `docs/informe.pdf` (máximo seis páginas) con 1.a, 2.c, mapa de motores (3.a), mantenimiento (3.b) y code review (3.c).
   - Agregar el mantenimiento al plan de Unidad 6 una vez localizado; responder cómo probar restauraciones, qué hacen las tablets ante un PostgreSQL restaurado desde un respaldo viejo y quién/cuándo revisa conflictos y rechazos.
   - Pedir a OpenCode, agente Plan, revisar todos los scripts de la cursada. Registrar hallazgos y decisiones; desarrollar al menos tres de dos unidades distintas, probarlos en la base y fundamentar al menos un hallazgo descartado.
7. **Cerrar entrega y defensa**
   - Completar `README.md` con el orden reproducible desde cero; `docs/bitacora_ia.md` con al menos tres entradas; `docs/DUIA.md` con la declaración oficial.
   - Preparar el ensayo de defensa de diez minutos: mapa de motores, un caso en vivo y un hallazgo de IA.
   - Verificar que la estructura acordada quede en `Unidad 8/food-store/`, que los scripts y evidencias se puedan repetir desde cero y que el `.zip` o etiqueta `tp8` contenga los entregables pedidos.

## Estructura objetivo

```text
Unidad 8/food-store/
├── README.md
├── movil/
│   ├── schema_sqlite.sql
│   ├── pruebas_sqlite.sql
│   ├── semaforo.sql
│   ├── servidor_snapshot.csv
│   └── foodstore_movil.db
└── docs/
    ├── informe.pdf
    ├── kiro/
    │   ├── requirements.md
    │   ├── design.md
    │   └── tasks.md
    ├── bitacora_ia.md
    └── DUIA.md
```

## Reglas y consideraciones

- La tablet solo consulta y guarda borradores: PostgreSQL decide precio, stock y ventas. `SIMULADO_APROBADO` no es una venta.
- Usar copias y datos inventados; no incluir contraseñas, correos ni datos personales reales en SQLite ni en prompts de IA.
- La Unidad 7 existente aporta el modelo/documentación de PostgreSQL y MongoDB. El estado actual del worktree muestra eliminaciones y directorios no rastreados; en Antigravity hay que preservarlos y no restaurar ni descartar cambios ajenos al TP 8.
- La consigna hace referencia a un plan de Unidad 6 y a una DUIA de cátedra que no están en los materiales visibles; obtenerlos antes de cerrar esos entregables.
- Para los scripts que dependen del apunte (vista de snapshot y protección real de idempotencia), verificar la parada correspondiente y el esquema concreto antes de generar SQL.
- Las pruebas y ejecuciones del trabajo quedan deliberadamente fuera de esta sesión y se realizarán en Antigravity.
