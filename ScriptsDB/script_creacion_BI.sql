PRINT 'Comienzo creación de tabla del modelo BI';

CREATE TABLE LA_EMPRESA.bi_anio_y_mes(
    id INTEGER IDENTITY(0,1) PRIMARY KEY,
    anio INT,
    mes INT CHECK (mes BETWEEN 1 AND 12)
);
PRINT 'Creada tabla Año y Mes';

CREATE TABLE LA_EMPRESA.bi_cliente (
    id INTEGER PRIMARY KEY,
    dni INTEGER NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    fecha_nac DATETIME NOT NULL,
    email VARCHAR(50) NOT NULL,
    telefono INTEGER NOT NULL
);
PRINT 'Creada tabla Cliente BI';

CREATE TABLE LA_EMPRESA.bi_proveedor (
    id INTEGER PRIMARY KEY,
    razon_social VARCHAR(100) NOT NULL
);
PRINT 'Creada tabla Proveedor BI';

CREATE TABLE LA_EMPRESA.bi_ciudad (
    codigo INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);
PRINT 'Creada tabla ciudad BI.'

CREATE TABLE LA_EMPRESA.bi_tipo_habitacion (
    codigo INT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);
PRINT 'Creada tabla bi_tipo_habitacion.'

CREATE TABLE LA_EMPRESA.bi_avion (
    identificador VARCHAR(50) NOT NULL PRIMARY KEY,
    modelo VARCHAR(50)
);
PRINT 'Creada tabla bi_avion.'

CREATE TABLE LA_EMPRESA.bi_ruta_aerea (
    codigo INT PRIMARY KEY
);

PRINT 'Creada tabla bi_ruta_aerea.'

CREATE TABLE LA_EMPRESA.bi_tipo_butaca (
    id INT IDENTITY(0,1) PRIMARY KEY,
    descripcion VARCHAR(50)
);
PRINT 'Creada bi_tabla_butaca.'

CREATE TABLE LA_EMPRESA.fact_table_estadia(
    id_anio_y_mes INT NOT NULL,
    id_cliente INT NOT NULL,
    id_empresa INT NOT NULL,
    id_tipo_habitacion INT NOT NULL,
    precio_promedio_compra INT NOT NULL,
    precio_promedio_venta INT NOT NULL,
    cantidad_de_camas_vendidas INT NOT NULL,
    cantidad_de_habitaciones_vendidas INT NOT NULL,
    ganancias_realizadas INT NOT NULL,
    FOREIGN KEY (id_anio_y_mes) REFERENCES LA_EMPRESA.bi_anio_y_mes (id),
    FOREIGN KEY (id_cliente) REFERENCES LA_EMPRESA.bi_cliente (id),
    FOREIGN KEY (id_empresa) REFERENCES LA_EMPRESA.bi_proveedor (id),
    FOREIGN KEY (id_tipo_habitacion) REFERENCES LA_EMPRESA.bi_tipo_habitacion (codigo)
);

PRINT 'Creada Fact Table de Estadias';

PRINT 'Comienzo carga del modelo BI';

PRINT 'El mismo se compone de dos Fact tables con sus respectivas dimensiones';

INSERT INTO LA_EMPRESA.bi_ciudad (codigo, nombre)
SELECT codigo, nombre FROM LA_EMPRESA.ciudad;

PRINT 'Migradas ciudades al modelo BI';

INSERT INTO LA_EMPRESA.bi_cliente (id, dni, apellido, nombre, email, fecha_nac, telefono)
SELECT id, dni, apellido, nombre, email, fecha_nac, telefono FROM LA_EMPRESA.cliente;

PRINT 'Migrados clientes al modelo BI';

INSERT INTO LA_EMPRESA.bi_proveedor (id, razon_social)
SELECT id, razon_social FROM LA_EMPRESA.empresa;

PRINT 'Migrados proveedores al modelo BI';

INSERT INTO LA_EMPRESA.bi_anio_y_mes (anio, mes)
SELECT DISTINCT YEAR(f.fecha), MONTH(f.fecha) FROM LA_EMPRESA.factura f JOIN LA_EMPRESA.pasaje p ON (p.codigo = f.id_servicio)
UNION
SELECT DISTINCT YEAR(f.fecha), MONTH(f.fecha) FROM LA_EMPRESA.factura f JOIN LA_EMPRESA.estadia e ON (e.codigo = f.id_servicio)

PRINT 'Migradas fechas con actividad al modelo BI';

INSERT INTO LA_EMPRESA.bi_tipo_habitacion (codigo, descripcion)
SELECT codigo, descripcion
FROM LA_EMPRESA.tipo_habitacion

PRINT 'Migrados tipos de habitaciones al modelo BI';

INSERT INTO LA_EMPRESA.bi_avion (identificador, modelo)
SELECT identificador, modelo
FROM LA_EMPRESA.avion

PRINT 'Migrados aviones al modelo BI';

INSERT INTO LA_EMPRESA.bi_ruta_aerea (codigo)
SELECT DISTINCT codigo
FROM LA_EMPRESA.ruta_aerea

PRINT 'Migradas rutas aereas al modelo BI';

INSERT INTO LA_EMPRESA.bi_tipo_butaca (descripcion)
SELECT DISTINCT tipo
FROM LA_EMPRESA.butaca

PRINT 'Migradas tipos de butacas al modelo BI';

INSERT INTO LA_EMPRESA.fact_table_estadia (id_anio_y_mes, id_cliente, id_empresa, id_tipo_habitacion,cantidad_de_camas_vendidas, precio_promedio_compra, precio_promedio_venta, cantidad_de_habitaciones_vendidas, ganancias_realizadas)
SELECT aym.id, cli.id, emp.id, th.codigo,
SUM(
    CASE
        WHEN th.codigo = 1001 THEN 1
        WHEN th.codigo = 1002 THEN 2
        WHEN th.codigo = 1003 THEN 3
        WHEN th.codigo = 1004 THEN 4
        WHEN th.codigo = 1005 THEN 1
    END
) 'Camas Vendidas', (Sum(h.costo) / COUNT(*)) 'Promedio de Compra',
   (Sum(h.precio) / COUNT(*)) 'Promedio de Venta', COUNT(*) 'Habitaciones Vendidas',
   (SUM(h.precio) - SUM(h.costo)) 'Ganancias Realizadas'
FROM LA_EMPRESA.factura f JOIN LA_EMPRESA.estadia e
ON (e.codigo = f.id_servicio) JOIN LA_EMPRESA.habitacion h
ON (h.id_habitacion = e.id_habitacion) JOIN LA_EMPRESA.bi_anio_y_mes aym
ON(aym.anio = YEAR(f.fecha) AND aym.mes = MONTH(f.fecha)) JOIN LA_EMPRESA.tipo_habitacion th
ON (th.codigo = h.id_tipo_habitacion) JOIN LA_EMPRESA.servicio s
ON (s.codigo = f.id_servicio) JOIN LA_EMPRESA.compra co
ON (co.numero = s.id_compra) JOIN LA_EMPRESA.empresa emp
ON(emp.id = co.id_empresa) JOIN LA_EMPRESA.cliente cli
ON (cli.id = f.id_cliente)
GROUP BY aym.id, cli.id, emp.id, th.codigo;

PRINT 'Llenado de Fact Table Estadia completo';