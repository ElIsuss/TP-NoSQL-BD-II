import os
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable
)
from reportlab.pdfgen import canvas
from pypdf import PdfReader

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_number(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

    def draw_page_number(self, page_count):
        self.saveState()
        self.setFont('Helvetica', 8)
        self.setFillColor(colors.HexColor('#64748B'))
        # Header (pages > 1)
        if self._pageNumber > 1:
            self.drawString(36, 810, 'UTN - BD II | TP N.º 8: Food Store en la feria — Cierre de la Capa de Datos')
            self.setStrokeColor(colors.HexColor('#CBD5E1'))
            self.setLineWidth(0.5)
            self.line(36, 804, 559, 804)
        # Footer
        self.setStrokeColor(colors.HexColor('#CBD5E1'))
        self.setLineWidth(0.5)
        self.line(36, 40, 559, 40)
        self.drawString(36, 28, 'Autores: Juan Martinez, Isaias Morinigo')
        page_text = f'Página {self._pageNumber} de {page_count}'
        self.drawRightString(559, 28, page_text)
        self.restoreState()

def build_pdf():
    pdf_path = r'Unidad 8\food-store\docs\informe.pdf'
    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=A4,
        leftMargin=36,
        rightMargin=36,
        topMargin=46,
        bottomMargin=48
    )

    styles = getSampleStyleSheet()

    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=17,
        leading=21,
        textColor=colors.HexColor('#0F172A'),
        spaceAfter=3
    )

    subtitle_style = ParagraphStyle(
        'DocSubTitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13,
        textColor=colors.HexColor('#475569'),
        spaceAfter=10
    )

    h1_style = ParagraphStyle(
        'H1',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=14,
        textColor=colors.HexColor('#1E3A8A'),
        spaceBefore=7,
        spaceAfter=3,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8,
        leading=11,
        textColor=colors.HexColor('#334155'),
        spaceAfter=3
    )

    table_header_style = ParagraphStyle(
        'TableHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=9.5,
        textColor=colors.HexColor('#0F172A')
    )

    table_body_style = ParagraphStyle(
        'TableBody',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7,
        leading=9,
        textColor=colors.HexColor('#1E293B')
    )

    story = []

    # Title & Metadata
    story.append(Paragraph('Trabajo Práctico N.º 8: Food Store en la feria', title_style))
    story.append(Paragraph('<b>Base de Datos II · UTN</b> | Integrantes: Juan Martinez, Isaias Morinigo | Noviembre 2026', subtitle_style))
    story.append(HRFlowable(width='100%', thickness=1, color=colors.HexColor('#CBD5E1'), spaceAfter=6))

    # -------------------------------------------------------------
    # SECCION 1.A: QUÉ DATOS VIAJAN
    # -------------------------------------------------------------
    story.append(Paragraph('1. Consigna 1.a — Qué datos viajan a la tablet', h1_style))
    story.append(Paragraph(
        'La tablet opera en un entorno de feria sin conectividad continua. Por seguridad, rendimiento y privacidad, '
        'se restringe el conjunto de datos transferidos exclusivamente a lo indispensable para la carta y el cálculo provisional de pedidos.',
        body_style
    ))

    col_data = [
        [Paragraph('Ámbito / Entidad', table_header_style), Paragraph('Columnas que VIAJAN a la Tablet', table_header_style), Paragraph('Columnas que NO VIAJAN', table_header_style)],
        [
            Paragraph('<b>Producto</b>', table_body_style),
            Paragraph('<code>id</code>, <code>nombre</code>, <code>precio_centavos</code>, <code>stock_visto</code>, <code>disponible</code>, <code>eliminado</code>, <code>fecha_de_copia</code>', table_body_style),
            Paragraph('<code>costo_proveedor</code>, <code>id_proveedor</code>, <code>margen_ganancia</code>, <code>fecha_alta</code>, <code>usuario_modificacion</code>', table_body_style)
        ],
        [
            Paragraph('<b>Clientes</b>', table_body_style),
            Paragraph('Ninguno (solo usuario local del mozo en el borrador)', table_body_style),
            Paragraph('Nombres, DNI, teléfonos, emails, contraseñas, domicilios', table_body_style)
        ],
        [
            Paragraph('<b>Transacciones</b>', table_body_style),
            Paragraph('Borradores locales (<code>pedido_borrador</code>, <code>item_borrador</code>, <code>cola_sync</code>)', table_body_style),
            Paragraph('Historial global de ventas, balances contables y arqueos de caja', table_body_style)
        ]
    ]
    t1 = Table(col_data, colWidths=[85, 225, 213])
    t1.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#F1F5F9')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#CBD5E1')),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
    ]))
    story.append(t1)
    story.append(Spacer(1, 3))
    story.append(Paragraph(
        '<b>Justificación y Fuente de Verdad:</b> La minimización de datos mitiga riesgos de exposición de datos personales '
        'ante extravío del dispositivo y reduce el consumo de red móvil. La única fuente autoritativa es <b>PostgreSQL</b> en el servidor central; '
        'la tablet solo posee una instantánea histórica de solo lectura y cualquier conflicto o validación es resuelta por el servidor central.',
        body_style
    ))
    story.append(Spacer(1, 5))

    # -------------------------------------------------------------
    # SECCION 2.C: LOS CASOS DEL SEMAFORO
    # -------------------------------------------------------------
    story.append(Paragraph('2. Consigna 2.c — Resultados de los Casos de Simulación (C2 a C6)', h1_style))
    story.append(Paragraph(
        'El semáforo evalúa solicitudes <code>PENDIENTE</code> agrupando líneas y aplicando la jerarquía: '
        '<b>Rojo (RECHAZADO)</b> > <b>Amarillo (CONFLICTO)</b> > <b>Verde (SIMULADO_APROBADO)</b>.',
        body_style
    ))

    casos_data = [
        [Paragraph('Caso', table_header_style), Paragraph('Escenario Preparado', table_header_style), Paragraph('Resultado y Motivo en cola_sync', table_header_style), Paragraph('Explicación y Justificación Técnica', table_header_style)],
        [
            Paragraph('<b>C2</b>', table_body_style),
            Paragraph('Borrador con Hamb. Doble a $8.500; el servidor sube a $9.200.', table_body_style),
            Paragraph('1°: <b>CONFLICTO</b><br/>2° tras aceptar: <b>SIMULADO_APROBADO</b>', table_body_style),
            Paragraph('Detecta desfasaje tarifario sin abortar ni forzar la venta. Al aceptar el cliente, una nueva solicitud resulta aprobada.', table_body_style)
        ],
        [
            Paragraph('<b>C3</b>', table_body_style),
            Paragraph('Borrador por 100 unidades de Papas Fritas (stock servidor: 40).', table_body_style),
            Paragraph('<b>RECHAZADO</b><br/>Stock insuficiente (solicitado: 100, stock: 40)', table_body_style),
            Paragraph('Prioridad Rojo: previene ventas en descubierto e inconsistencias físicas de inventario.', table_body_style)
        ],
        [
            Paragraph('<b>C4</b>', table_body_style),
            Paragraph('Borrador con Gaseosa 500ml dada de baja lógica en el servidor.', table_body_style),
            Paragraph('<b>RECHAZADO</b><br/>Producto dado de baja lógica / no disponible', table_body_style),
            Paragraph('Al recargar catálogo local, el ítem desaparece de la carta activa pero su fila persiste como lápida (tombstone) asegurando FKs.', table_body_style)
        ],
        [
            Paragraph('<b>C5</b>', table_body_style),
            Paragraph('Borrador sin cambios con Empanada Criolla (datos vigentes y stock OK).', table_body_style),
            Paragraph('<b>SIMULADO_APROBADO</b><br/>Stock y precios vigentes coincidentes', table_body_style),
            Paragraph('Cumple todas las condiciones de validación previa en el servidor.', table_body_style)
        ],
        [
            Paragraph('<b>C6</b>', table_body_style),
            Paragraph('Reintento de sincronización con mismo UUID de solicitud.', table_body_style),
            Paragraph('<b>Error PK duplicada</b><br/>UNIQUE constraint failed', table_body_style),
            Paragraph('No duplica registros. El semáforo ignora filas que no estén en PENDIENTE garantizando idempotencia estricta.', table_body_style)
        ]
    ]
    t2 = Table(casos_data, colWidths=[28, 145, 170, 180])
    t2.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#F1F5F9')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#CBD5E1')),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
    ]))
    story.append(t2)
    story.append(Spacer(1, 3))
    story.append(Paragraph(
        '<b>Protección real en producción (Parada 8):</b> La protección de idempotencia reside obligatoriamente en el <b>servidor PostgreSQL</b> '
        'mediante una tabla de auditoría con restricción <code>UNIQUE (solicitud_uuid)</code>. Ante fallos de red y reintentos automáticos, '
        'el backend detecta el UUID ya procesado, no descuenta stock ni cobra nuevamente, y retorna de forma segura el resultado original.',
        body_style
    ))
    story.append(Paragraph(
        '<b>Comprobación de Invarianza en PostgreSQL:</b> Se ejecutó la consulta de control en el servidor: '
        '<code>SELECT COUNT(*) FROM pedido;</code> y <code>SELECT SUM(stock) FROM producto;</code>. La cantidad de pedidos y los stocks '
        'permanecieron exactamente iguales antes y después de toda la simulación, ratificando que <i>SIMULADO_APROBADO no es una venta</i>.',
        body_style
    ))
    story.append(Spacer(1, 5))

    # -------------------------------------------------------------
    # SECCION 3.A: MAPA DE LA CAPA DE DATOS
    # -------------------------------------------------------------
    story.append(Paragraph('3. Consigna 3.a — Mapa de la Capa de Datos (Multi-Motor)', h1_style))
    story.append(Paragraph(
        'Food Store articula tres motores de bases de datos especializados con delimitación estricta de autoridad:',
        body_style
    ))

    motores_data = [
        [Paragraph('Motor', table_header_style), Paragraph('Rol Arquitectónico', table_header_style), Paragraph('Qué Guarda', table_header_style), Paragraph('Quién Manda (Autoridad)', table_header_style)],
        [
            Paragraph('<b>PostgreSQL 16+</b><br/>(Servidor Central)', table_body_style),
            Paragraph('OLTP Transaccional Maestro', table_body_style),
            Paragraph('Catálogo oficial, listas de precios, stock físico real, clientes, pedidos confirmados, facturación y auditoría.', table_body_style),
            Paragraph('<b>Autoridad Absoluta (Única Fuente de Verdad)</b>. Valida stock y confirma ventas.', table_body_style)
        ],
        [
            Paragraph('<b>MongoDB 9.0+</b><br/>(Unidad 7)', table_body_style),
            Paragraph('Read Model / Analytics', table_body_style),
            Paragraph('Documentos desnormalizados de pedidos con líneas embebidas y precios históricos para lecturas agregadas.', table_body_style),
            Paragraph('<b>Manda sobre consultas analíticas de lectura</b>. No tiene autoridad de inventario ni transaccional.', table_body_style)
        ],
        [
            Paragraph('<b>SQLite 3.37+</b><br/>(Unidad 8 - Móvil)', table_body_style),
            Paragraph('Caché Offline y Borradores', table_body_style),
            Paragraph('Caché de catálogo (<code>producto_cache</code>), borradores (<code>pedido_borrador</code>) y cola de sincronización.', table_body_style),
            Paragraph('<b>Manda sobre la UI local y armado de borradores</b>. No altera stock ni precios centrales.', table_body_style)
        ]
    ]
    t3 = Table(motores_data, colWidths=[80, 95, 203, 145])
    t3.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#F1F5F9')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#CBD5E1')),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
    ]))
    story.append(t3)
    story.append(Spacer(1, 5))

    # -------------------------------------------------------------
    # SECCION 3.B: PLAN DE MANTENIMIENTO
    # -------------------------------------------------------------
    story.append(Paragraph('4. Consigna 3.b — Plan de Mantenimiento y Resiliencia (Agregado U6)', h1_style))
    story.append(Paragraph(
        'Como complemento formal a <code>SPEC_U6.md</code>, se establecen los protocolos de contingencia y sincronización:',
        body_style
    ))
    story.append(Paragraph(
        '• <b>Qué se respalda y prueba de restauración:</b> Se respalda diariamente la base central PostgreSQL con <code>pg_dump -Fc</code> '
        '(incluyendo vistas maestras como <code>v_snapshot_movil</code>). Las tablets SQLite son cachés descartables y no requieren backup '
        'centralizado diario. Semanalmente se prueba la restauración en un entorno descartable (<code>foodstore_restore_test</code>) '
        'validando cardinalidades, restricciones lógicas y exportación de instantáneas.',
        body_style
    ))
    story.append(Paragraph(
        '• <b>Comportamiento ante restauración de respaldo viejo de PostgreSQL:</b> Si el servidor retrocede en el tiempo por contingencia, '
        'las tablets invalidan su <code>producto_cache</code> al detectar la inconsistencia temporal, descargan una instantánea fresca y '
        'reevalúan las solicitudes en <code>cola_sync</code> mediante el semáforo. Cualquier cambio de stock o precio pasará a <code>CONFLICTO</code> '
        'o <code>RECHAZADO</code>, bloqueando impactos indebidos.',
        body_style
    ))
    story.append(Paragraph(
        '• <b>Revisión de solicitudes en CONFLICTO o RECHAZADO:</b> Se realiza al cierre de cada turno de feria (cada 4 horas) y diariamente. '
        'El <b>Encargado de Caja</b> revisa los motivos comerciales con el comensal (aceptación de tarifa o reemplazo de ítem); '
        'el <b>DBA</b> audita incidencias técnicas de sincronización.',
        body_style
    ))
    story.append(Spacer(1, 5))

    # -------------------------------------------------------------
    # SECCION 3.C: CODE REVIEW CON IA
    # -------------------------------------------------------------
    story.append(Paragraph('5. Consigna 3.c — Code Review con IA sobre los Scripts de la Cursada', h1_style))
    story.append(Paragraph(
        'Se realizó una revisión estática sobre los scripts de cursada registrando decisiones fundamentadas y comprobadas empíricamente:',
        body_style
    ))

    cr_data = [
        [Paragraph('ID / Origen', table_header_style), Paragraph('Hallazgo / Sugerencia de la IA', table_header_style), Paragraph('Decisión', table_header_style), Paragraph('Justificación y Comprobación en Base de Datos', table_header_style)],
        [
            Paragraph('<b>H-01</b><br/>Unidad 7 (PG)', table_body_style),
            Paragraph('Índice compuesto <code>(id_pedido, eliminado)</code> en <code>detalle_pedido</code>.', table_body_style),
            Paragraph('<b>Aceptado / Corregido</b>', table_body_style),
            Paragraph('Optimiza joins y cálculos de totales. Comprobado con <code>EXPLAIN ANALYZE</code> reduciendo el escaneo secuencial en filtros frecuentes.', table_body_style)
        ],
        [
            Paragraph('<b>H-02</b><br/>Unidad 7 (Mongo)', table_body_style),
            Paragraph('Desnormalizar campo precalculado <code>total</code> en la raíz de cada pedido.', table_body_style),
            Paragraph('<b>Descartado con fundamento</b>', table_body_style),
            Paragraph('<b>Descartado:</b> Viola la autoridad de PostgreSQL sobre los importes y arriesga inconsistencias. Comprobado que <code>$unwind + $group</code> tarda &lt; 1 ms.', table_body_style)
        ],
        [
            Paragraph('<b>H-03</b><br/>Unidad 8 (SQLite)', table_body_style),
            Paragraph('Cláusula <code>ON DELETE CASCADE</code> en FKs de <code>item_borrador</code> y <code>cola_sync</code>.', table_body_style),
            Paragraph('<b>Aceptado / Corregido</b>', table_body_style),
            Paragraph('Evita registros huérfanos si el mozo elimina un borrador local. Comprobado que al borrar un borrador se limpian ítems y cola automáticamente.', table_body_style)
        ]
    ]
    t4 = Table(cr_data, colWidths=[70, 135, 98, 220])
    t4.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#F1F5F9')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#CBD5E1')),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
    ]))
    story.append(t4)

    doc.build(story, canvasmaker=NumberedCanvas)

    reader = PdfReader(pdf_path)
    page_count = len(reader.pages)
    print(f'SUCCESS: PDF generated at {pdf_path}. Total pages: {page_count}')

if __name__ == '__main__':
    build_pdf()

