# Food Store — TP N.º 8: Food Store en la feria

## La base de la tablet y el cierre de la capa de datos

**Asignatura**: Base de Datos II · Tecnicatura Universitaria en Programación (UTN)  
**Integrantes**: Juan Martinez, Isaias Morinigo  
**Entorno técnico**: PostgreSQL 16+, SQLite 3.37+, Python 3.14  

---

## 1. Estructura del Repositorio

```text
food-store/
├── README.md                          <-- Guía de reproducción y ensayo de defensa
├── movil/
│   ├── schema_sqlite.sql              <-- Consigna 1.b: DDL SQLite STRICT, staging y FK activadas
│   ├── pruebas_sqlite.sql             <-- Consigna 1.c: Transacciones, Caso C1 y C7
│   ├── v_snapshot_movil.sql           <-- Consigna 2.a: Vista PostgreSQL para exportar el catálogo
│   ├── semaforo.sql                   <-- Consigna 2.b: Lógica SQL del Semáforo
│   ├── servidor_snapshot.csv          <-- Consigna 2.a: Instantánea exportada del servidor
│   ├── casos_simulacion.sql           <-- Consigna 2.c: Casos C2 a C6 reproducibles
│   └── foodstore_movil.db             <-- Base de datos SQLite generada y validada
└── docs/
    ├── informe.pdf                    <-- Informe final consolidado (máx. 6 páginas)
    ├── kiro/                          <-- Consigna 4.a: Especificación previa
    │   ├── requirements.md            <-- 4 requisitos EARS vinculados a casos
    │   ├── design.md                  <-- Principios arquitectónicos y DDL
    │   └── tasks.md                   <-- Checklist de tareas de implementación
    ├── bitacora_ia.md                 <-- Consigna 4.b: 3 entradas con pedidos y descartes
    └── DUIA.md                        <-- Declaración de Uso de IA de la cátedra
```

---

## 2. Orden de Reproducción desde Cero

Para recrear y validar la totalidad del proyecto desde cero, siga los siguientes pasos:

### Paso 1: Creación del Esquema Móvil (Consigna 1.b)
Crea las cuatro tablas móviles `STRICT`, la tabla de staging del snapshot y activa las claves foráneas:
```bash
sqlite3 movil/foodstore_movil.db < movil/schema_sqlite.sql
```

### Paso 2: Ejecución de Pruebas Unitarias y Restricciones (Consigna 1.c)
Verifica transacciones (`COMMIT`/`ROLLBACK`), catálogo offline disponible (Caso C1) y control de errores (Caso C7):
```bash
sqlite3 movil/foodstore_movil.db < movil/pruebas_sqlite.sql
```

### Paso 3: Carga de la Instantánea del Servidor (Consigna 2.a)
Desde `psql`, conectado a la base PostgreSQL de Food Store y con el directorio actual en `food-store`, crea la vista y exporta el CSV:
```sql
\i movil/v_snapshot_movil.sql
\copy (SELECT id, nombre, precio_centavos, stock, disponible, eliminado FROM v_snapshot_movil ORDER BY id) TO 'movil/servidor_snapshot.csv' WITH CSV HEADER
```

Luego, dentro de `sqlite3 movil/foodstore_movil.db`, importa el CSV en la tabla de staging creada en el Paso 1:
```sql
.mode csv
.import --skip 1 movil/servidor_snapshot.csv snapshot_servidor
```

### Paso 4: Ejecución de Casos de Sincronización y Semáforo (Consigna 2.b y 2.c)
Ejecuta primero el semáforo para cargar el catálogo importado en `producto_cache` y validar las solicitudes de pruebas previas. Después carga los borradores C2, C3, C4 y C5 y vuelve a ejecutar el semáforo:
```bash
sqlite3 movil/foodstore_movil.db < movil/semaforo.sql
sqlite3 movil/foodstore_movil.db < movil/casos_simulacion.sql
sqlite3 movil/foodstore_movil.db < movil/semaforo.sql
```
El caso C6 se demuestra intentando insertar otra vez un UUID ya existente (por ejemplo, el de C5); la clave primaria de `cola_sync` debe rechazarlo. El CSV representa el esquema actual, que no tiene una columna independiente de baja lógica: `activo` se exporta como `disponible` y `eliminado` queda en `FALSE`. La baja lógica del caso C4 se simula explícitamente en `snapshot_servidor`.

Para comprobar C6 en `sqlite3` después de los pasos anteriores, se puede repetir esta inserción: debe fallar por `UNIQUE constraint failed`.
```sql
INSERT INTO cola_sync (solicitud_uuid, id_local, estado, motivo)
VALUES (
  's5555555-aaaa-5555-5555-555555555555',
  'b5555555-5555-5555-5555-555555555555',
  'PENDIENTE',
  'Reintento'
);
```

---

## 3. Guion para el Ensayo de Defensa (10 Minutos)

Para la presentación oral de la semana 13, se estructuran los 10 minutos de la siguiente manera:

### Minutos 0 a 3: El Mapa de la Capa de Datos (Consigna 3.a)
- **Concepto clave**: *"El móvil propone, el servidor dispone"*.
- **PostgreSQL**: Es la autoridad máxima y única fuente de verdad; valida stock real, precios vigentes y confirma ventas.
- **MongoDB (U7)**: Proyección documental desnormalizada optimizada para lectura rápida de pedidos cerrados y reportería, sin interferir en el OLTP.
- **SQLite (U8)**: Base móvil local para el food truck en la feria sin conexión. Permite consultar la carta y armar borradores de pedidos en modo offline. `SIMULADO_APROBADO` nunca es una venta.

### Minutos 3 a 7: Demostración del Semáforo en Vivo (Consigna 2.c - Caso C2 / C6)
- **Demostración en vivo en SQLite**:
  1. Mostrar un borrador pendiente con la Hamburguesa a \$8.500.
  2. Modificar el precio en `snapshot_servidor` a \$9.200 y correr el semáforo.
  3. Evidenciar cómo el estado pasa automáticamente a `CONFLICTO` (*Amarillo*).
  4. Mostrar cómo al aceptar el cliente el precio, se actualiza el borrador y una nueva solicitud obtiene `SIMULADO_APROBADO` (*Verde*).
  5. Mostrar el intento de reenviar con el mismo UUID (Caso C6), arrojando error de clave primaria y demostrando la protección de idempotencia.

### Minutos 7 a 10: Análisis de un Hallazgo de la IA y Conclusiones (Consigna 3.c)
- **Hallazgo descartado**: La IA sugirió guardar el campo `total_pedido` precalculado en MongoDB para ahorrarse el `$unwind` + `$group`.
- **Fundamento del descarte**: Se descartó porque PostgreSQL es la autoridad sobre las líneas facturadas y duplicar el total generaría riesgo de desincronización ante notas de crédito o ajustes. Se comprobó en laboratorio que la agregación nativa tarda menos de 1 ms.
- **Conclusión**: La arquitectura desacoplada garantiza operatividad al 100% en ferias sin señal, protegiendo la integridad del negocio central.
