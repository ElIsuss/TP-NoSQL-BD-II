# Consigna 1.a — Qué datos viajan a la tablet

## Tabla de datos que viajan vs. datos que no viajan

| Entidad / Ámbito | Columnas / Datos que viajan | Columnas / Datos que NO viajan |
| :--- | :--- | :--- |
| **Producto** | `id`, `nombre`, `precio_centavos`, `stock_visto`, `disponible`, `eliminado`, `fecha_de_copia` | `costo_proveedor`, `id_proveedor`, `margen_ganancia`, `fecha_alta_servidor`, `usuario_modificacion` |
| **Clientes / Usuarios** | Ninguno (solo se registra el identificador de usuario local del operador/mozo en el borrador) | Nombres, DNI, correos electrónicos, teléfonos, contraseñas y direcciones de clientes |
| **Transacciones / Finanzas** | Solo borradores locales generados en el dispositivo (`pedido_borrador`, `item_borrador`, `cola_sync`) | Historial global de pedidos, facturación centralizada, arqueos de caja del servidor |

## Justificación y Fuente de Verdad

La tablet opera en un entorno móvil y expuesto en la feria, por lo que transferir únicamente los campos estrictamente necesarios para exhibir el catálogo y calcular montos provisionales minimiza el consumo de red y resguarda la privacidad ante un eventual extravío o robo del equipo. 

La única fuente de verdad autoritativa sobre el catálogo, el inventario y las ventas es la base de datos central en **PostgreSQL**; los datos en la tablet constituyen una instantánea temporal de solo lectura y cualquier conflicto o decisión final de venta es resuelta por el servidor.

