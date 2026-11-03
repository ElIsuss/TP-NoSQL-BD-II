# Plan de Tareas de Implementación (Kiro Tasks)

## Fase 1: Base de Datos Móvil SQLite (Consigna 1)
- [x] **Tarea 1.1**: Documentar política de datos ("Qué datos viajan") identificando columnas de producto, datos excluidos y fuente de verdad.
- [x] **Tarea 1.2**: Implementar `movil/schema_sqlite.sql` con `PRAGMA foreign_keys = ON;` y 4 tablas en modo `STRICT`.
- [x] **Tarea 1.3**: Implementar `movil/pruebas_sqlite.sql` validando transacciones (COMMIT/ROLLBACK), Caso C1 (catálogo offline) y Caso C7 (rechazo de cantidad cero y producto inexistente).
- [x] **Tarea 1.4**: Ejecutar scripts y generar `movil/foodstore_movil.db`.

## Fase 2: Sincronización y Simulación del Semáforo (Consigna 2)
- [x] **Tarea 2.1**: Definir vista `v_snapshot_movil` en PostgreSQL y formato CSV para exportación (`servidor_snapshot.csv`).
- [x] **Tarea 2.2**: Desarrollar `movil/semaforo.sql` con prioridades Rojo (RECHAZADO), Amarillo (CONFLICTO) y Verde (SIMULADO_APROBADO).
- [x] **Tarea 2.3**: Simular y registrar casos C2 a C6 demostrando idempotencia e invariancia en el servidor central.

## Fase 3: Integración, Mantenimiento y Code Review (Consigna 3)
- [x] **Tarea 3.1**: Elaborar mapa arquitectónico de los tres motores (PostgreSQL, MongoDB U7, SQLite U8).
- [x] **Tarea 3.2**: Completar sección de mantenimiento y resiliencia ante desastres.
- [x] **Tarea 3.3**: Ejecutar Code Review con IA sobre los scripts de la cursada, documentando decisiones fundamentadas.

## Fase 4: Documentación Final y Cierre de Entrega (Consigna 4)
- [x] **Tarea 4.1**: Completar `docs/bitacora_ia.md` y `docs/DUIA.md`.
- [x] **Tarea 4.2**: Elaborar `README.md` con instrucciones reproducibles paso a paso y ensayo de defensa.
- [x] **Tarea 4.3**: Compilar `docs/informe.pdf` (máximo 6 páginas) reuniendo 1.a, 2.c, 3.a, 3.b y 3.c.
