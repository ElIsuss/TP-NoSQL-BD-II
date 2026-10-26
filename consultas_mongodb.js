// TP Unidad 7 - NoSQL y nuevas formas de almacenamiento
// Origen: PostgreSQL, base foodstore
// Destino: food_store_nosql, coleccion pedidos
// Subconjunto: pedidos con IDs originales 1 a 5
// Los datos identificatorios de clientes se anonimizan para no publicar datos personales.

db = db.getSiblingDB("food_store_nosql");

if (!db.getCollectionNames().includes("pedidos")) {
  db.createCollection("pedidos");
}

const pedidos = [
  {
    _id: 1,
    fecha_hora: ISODate("2026-03-02T10:59:23.002-03:00"),
    fecha_hora_origen: "2026-03-02T10:59:23.002876-03:00",
    forma_pago: "TARJETA",
    estado: "PENDIENTE",
    cliente: {
      id_cliente: 5240,
      nombre: "Cliente 5240 (anonimizado)"
    },
    productos: [
      { id_detalle_pedido: 1, id_producto: 3485, nombre: "Producto 3485", cantidad: 10, precio_unitario: NumberDecimal("4602.06") },
      { id_detalle_pedido: 2, id_producto: 5684, nombre: "Producto 5684", cantidad: 20, precio_unitario: NumberDecimal("1821.07") },
      { id_detalle_pedido: 3, id_producto: 17365, nombre: "Producto 17365", cantidad: 18, precio_unitario: NumberDecimal("5257.88") }
    ]
  },
  {
    _id: 2,
    fecha_hora: ISODate("2026-07-30T21:41:46.249-03:00"),
    fecha_hora_origen: "2026-07-30T21:41:46.249399-03:00",
    forma_pago: "TRANSFERENCIA",
    estado: "PENDIENTE",
    cliente: {
      id_cliente: 13999,
      nombre: "Cliente 13999 (anonimizado)"
    },
    productos: [
      { id_detalle_pedido: 4, id_producto: 680, nombre: "Producto 680", cantidad: 12, precio_unitario: NumberDecimal("2471.43") },
      { id_detalle_pedido: 5, id_producto: 5086, nombre: "Producto 5086", cantidad: 13, precio_unitario: NumberDecimal("1104.61") },
      { id_detalle_pedido: 6, id_producto: 7991, nombre: "Producto 7991", cantidad: 17, precio_unitario: NumberDecimal("1867.75") },
      { id_detalle_pedido: 7, id_producto: 21979, nombre: "Producto 21979", cantidad: 16, precio_unitario: NumberDecimal("5478.70") },
      { id_detalle_pedido: 8, id_producto: 27033, nombre: "Producto 27033", cantidad: 9, precio_unitario: NumberDecimal("4213.71") }
    ]
  },
  {
    _id: 3,
    fecha_hora: ISODate("2025-05-26T08:50:26.078-03:00"),
    fecha_hora_origen: "2025-05-26T08:50:26.078931-03:00",
    forma_pago: "EFECTIVO",
    estado: "PENDIENTE",
    cliente: {
      id_cliente: 8675,
      nombre: "Cliente 8675 (anonimizado)"
    },
    productos: [
      { id_detalle_pedido: 9, id_producto: 9590, nombre: "Producto 9590", cantidad: 5, precio_unitario: NumberDecimal("1006.17") },
      { id_detalle_pedido: 10, id_producto: 15650, nombre: "Producto 15650", cantidad: 6, precio_unitario: NumberDecimal("2509.14") },
      { id_detalle_pedido: 11, id_producto: 23360, nombre: "Producto 23360", cantidad: 14, precio_unitario: NumberDecimal("1797.21") },
      { id_detalle_pedido: 12, id_producto: 44776, nombre: "Producto 44776", cantidad: 8, precio_unitario: NumberDecimal("4909.06") }
    ]
  },
  {
    _id: 4,
    fecha_hora: ISODate("2026-02-15T18:57:38.228-03:00"),
    fecha_hora_origen: "2026-02-15T18:57:38.228896-03:00",
    forma_pago: "TARJETA",
    estado: "PENDIENTE",
    cliente: {
      id_cliente: 5580,
      nombre: "Cliente 5580 (anonimizado)"
    },
    productos: [
      { id_detalle_pedido: 13, id_producto: 31635, nombre: "Producto 31635", cantidad: 4, precio_unitario: NumberDecimal("9177.95") },
      { id_detalle_pedido: 14, id_producto: 39507, nombre: "Producto 39507", cantidad: 10, precio_unitario: NumberDecimal("6614.84") },
      { id_detalle_pedido: 15, id_producto: 43686, nombre: "Producto 43686", cantidad: 5, precio_unitario: NumberDecimal("6291.38") },
      { id_detalle_pedido: 16, id_producto: 44566, nombre: "Producto 44566", cantidad: 19, precio_unitario: NumberDecimal("8874.63") }
    ]
  },
  {
    _id: 5,
    fecha_hora: ISODate("2024-12-14T07:42:00.840-03:00"),
    fecha_hora_origen: "2024-12-14T07:42:00.840984-03:00",
    forma_pago: "TRANSFERENCIA",
    estado: "PENDIENTE",
    cliente: {
      id_cliente: 10045,
      nombre: "Cliente 10045 (anonimizado)"
    },
    productos: [
      { id_detalle_pedido: 17, id_producto: 35819, nombre: "Producto 35819", cantidad: 20, precio_unitario: NumberDecimal("5012.78") }
    ]
  }
];

db.pedidos.bulkWrite(
  pedidos.map(pedido => ({
    replaceOne: {
      filter: { _id: pedido._id },
      replacement: pedido,
      upsert: true
    }
  }))
);

const idsSeleccionados = pedidos.map(pedido => pedido._id);

// a) Listar los pedidos migrados con identificador y estado.
print("=== 1. Pedidos migrados: _id y estado ===");
db.pedidos.find(
  { _id: { $in: idsSeleccionados } },
  { _id: 1, estado: 1 }
).sort({ _id: 1 }).forEach(printjson);

// b) Filtrar por un estado existente en el subconjunto.
print("\n=== 2. Pedidos con estado PENDIENTE ===");
db.pedidos.find(
  { _id: { $in: idsSeleccionados }, estado: "PENDIENTE" },
  { _id: 1, estado: 1, forma_pago: 1 }
).sort({ _id: 1 }).forEach(printjson);

// c) Buscar pedidos que contengan el producto 3485 dentro del arreglo.
print("\n=== 3. Pedidos con el producto id_producto 3485 ===");
db.pedidos.find(
  { _id: { $in: idsSeleccionados }, "productos.id_producto": 3485 },
  { _id: 1, "productos.$": 1 }
).sort({ _id: 1 }).forEach(printjson);

// d) El umbral de $250.000 selecciona pedidos de importe alto en este subconjunto.
// El total usa los precios históricos de cada línea y aritmética decimal.
print("\n=== 4. Pedidos con total mayor a $250.000 ===");
db.pedidos.aggregate([
  { $match: { _id: { $in: idsSeleccionados } } },
  { $unwind: "$productos" },
  {
    $group: {
      _id: "$_id",
      total: {
        $sum: {
          $multiply: ["$productos.cantidad", "$productos.precio_unitario"]
        }
      },
      estado: { $first: "$estado" },
      forma_pago: { $first: "$forma_pago" }
    }
  },
  { $match: { total: { $gt: NumberDecimal("250000.00") } } },
  { $sort: { total: -1 } }
]).forEach(printjson);

// Evidencia de IDs, fechas exactas del origen, cliente anonimizado y lineas migradas.
print("\n=== 5. Verificacion del subconjunto migrado (sin datos personales) ===");
db.pedidos.find(
  { _id: { $in: idsSeleccionados } },
  {
    _id: 1,
    fecha_hora_origen: 1,
    forma_pago: 1,
    estado: 1,
    "cliente.id_cliente": 1,
    productos: 1
  }
).sort({ _id: 1 }).forEach(printjson);
