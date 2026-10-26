// TP Unidad 7 - NoSQL y nuevas formas de almacenamiento
// Base de destino: food_store_nosql
// Coleccion: pedidos
// Origen: PostgreSQL, foods_store_completo
// Pedidos seleccionados: 1, 2, 3, 4 y 5

db.createCollection("pedidos");

db.pedidos.insertMany([
  {
    _id: 1,
    fecha_hora: ISODate("2024-10-27T09:41:22.038-03:00"),
    forma_pago: "TARJETA",
    estado: "PENDIENTE",

    cliente: {
      id_cliente: 7424,
      nombre: "Nombre7424",
      apellido: "Apellido7424",
      correo_electronico: "usuario_7424@foodstore.com",
      telefono: "+549000007424"
    },

    productos: [
      {
        id_detalle_pedido: 1,
        id_producto: 5563,
        nombre: "Producto 5563",
        cantidad: 4,
        precio_unitario: 5042.09
      },
      {
        id_detalle_pedido: 2,
        id_producto: 19035,
        nombre: "Producto 19035",
        cantidad: 7,
        precio_unitario: 9528.96
      },
      {
        id_detalle_pedido: 3,
        id_producto: 22671,
        nombre: "Producto 22671",
        cantidad: 19,
        precio_unitario: 9352.72
      },
      {
        id_detalle_pedido: 4,
        id_producto: 25679,
        nombre: "Producto 25679",
        cantidad: 8,
        precio_unitario: 424.61
      },
      {
        id_detalle_pedido: 5,
        id_producto: 31350,
        nombre: "Producto 31350",
        cantidad: 15,
        precio_unitario: 4878.73
      }
    ]
  },

  {
    _id: 2,
    fecha_hora: ISODate("2025-04-10T20:21:02.820-03:00"),
    forma_pago: "TRANSFERENCIA",
    estado: "PENDIENTE",

    cliente: {
      id_cliente: 9972,
      nombre: "Nombre9972",
      apellido: "Apellido9972",
      correo_electronico: "usuario_9972@foodstore.com",
      telefono: "+549000009972"
    },

    productos: [
      {
        id_detalle_pedido: 6,
        id_producto: 36905,
        nombre: "Producto 36905",
        cantidad: 3,
        precio_unitario: 1494.68
      }
    ]
  },

  {
    _id: 3,
    fecha_hora: ISODate("2024-10-22T19:48:20.975-03:00"),
    forma_pago: "EFECTIVO",
    estado: "PENDIENTE",

    cliente: {
      id_cliente: 13218,
      nombre: "Nombre13218",
      apellido: "Apellido13218",
      correo_electronico: "usuario_13218@foodstore.com",
      telefono: "+549000013218"
    },

    productos: [
      {
        id_detalle_pedido: 7,
        id_producto: 34662,
        nombre: "Producto 34662",
        cantidad: 3,
        precio_unitario: 8780.60
      }
    ]
  },

  {
    _id: 4,
    fecha_hora: ISODate("2026-08-17T00:03:06.529-03:00"),
    forma_pago: "TARJETA",
    estado: "PENDIENTE",

    cliente: {
      id_cliente: 468,
      nombre: "Nombre468",
      apellido: "Apellido468",
      correo_electronico: "usuario_468@foodstore.com",
      telefono: "+549000000468"
    },

    productos: [
      {
        id_detalle_pedido: 8,
        id_producto: 2055,
        nombre: "Producto 2055",
        cantidad: 20,
        precio_unitario: 760.28
      },
      {
        id_detalle_pedido: 9,
        id_producto: 22056,
        nombre: "Producto 22056",
        cantidad: 8,
        precio_unitario: 3535.09
      }
    ]
  },

  {
    _id: 5,
    fecha_hora: ISODate("2026-05-25T08:49:38.342-03:00"),
    forma_pago: "TRANSFERENCIA",
    estado: "PENDIENTE",

    cliente: {
      id_cliente: 16839,
      nombre: "Nombre16839",
      apellido: "Apellido16839",
      correo_electronico: "usuario_16839@foodstore.com",
      telefono: "+549000016839"
    },

    productos: [
      {
        id_detalle_pedido: 10,
        id_producto: 44839,
        nombre: "Producto 44839",
        cantidad: 2,
        precio_unitario: 5395.76
      }
    ]
  }
]);