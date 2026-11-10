# Declaración de Uso de Inteligencia Artificial (DUIA)

**Universidad Tecnológica Nacional (UTN)**  
**Tecnicatura Universitaria en Programación**  
**Cátedra**: Base de Datos II  
**Ciclo Lectivo**: 2026  
**Trabajo Práctico**: Trabajo Práctico N.º 7 — NoSQL y nuevas formas de almacenamiento (Food Store)  
**Integrantes del Equipo**:
- Juan Martinez
- Isaias Morinigo

---

### 1. Declaración de Herramientas Utilizadas

En el marco del TP N.º 7 se utilizó asistencia de IA generativa para:
- La comparación entre PostgreSQL y MongoDB (prompt documentado en `explicacion.md`).
- La generación y validación de consultas documentales y relacionales.

### 2. Alcance y Propósito del Uso de IA

La IA se empleó como herramienta colaborativa para:
1. **Comparación de tecnologías:** se solicitó una comparación entre PostgreSQL y MongoDB para el dominio de pedidos, considerando integridad, transacciones, agregación, escalabilidad de lectura y consistencia. La IA recomendó conservar PostgreSQL como fuente autoritativa y usar MongoDB como proyección de lectura.
2. **Propuesta de desnormalización:** la IA sugirió desnormalizar un campo `total` precalculado en MongoDB. Esta sugerencia fue **descartada** con fundamento (ver `explicacion.md` §4.4 y hallazgo H-02 en `Unidad 8/food-store/docs/consigna_3.md`).

### 3. Validación y Decisión Humana

- La afirmación de la IA sobre integridad referencial (PostgreSQL vs. MongoDB) se validó contra la documentación oficial de ambos motores.
- La afirmación sobre la desnormalización del `total` se validó ejecutando la agregación en laboratorio (< 1 ms sobre 17 líneas), concluyendo que la ganancia es despreciable frente al riesgo de desincronización.
- La migración de 5 pedidos (17 líneas) se verificó campo por campo entre ambos motores (`evidencias/comparacion_integridad.txt`).

### 4. Compromiso de Integridad Académica

- No se enviaron datos personales ni sensibles a la IA (las etiquetas de cliente se anonimizaron).
- Toda recomendación de la IA fue contrastada con evidencia empírica antes de aceptarla o descartarla.
- Los integrantes comprendemos el modelo documental y la justificación de la tecnología seleccionada y estamos preparados para defenderla oralmente.

### 5. Trazabilidad

Comparación completa: `explicacion.md`. Evidencias: `evidencias/`. Hallazgo H-02: `Unidad 8/food-store/docs/consigna_3.md`.