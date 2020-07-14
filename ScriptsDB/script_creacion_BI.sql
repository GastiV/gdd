PRINT 'Comienzo creación de tabla del modelo BI';

CREATE TABLE LOW_STRESS_DESIGN.bi_anio_y_mes(
    id INTEGER IDENTITY(0,1) PRIMARY KEY,
    anio INT,
    mes INT CHECK (mes BETWEEN 1 AND 12)
);
PRINT 'Creada tabla Año y Mes';

CREATE TABLE LOW_STRESS_DESIGN.bi_cliente (
    id INTEGER PRIMARY KEY,
    dni INTEGER NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    fecha_nac DATETIME NOT NULL,
    email VARCHAR(50) NOT NULL,
    telefono INTEGER NOT NULL
);
PRINT 'Creada tabla Cliente BI';

CREATE TABLE LOW_STRESS_DESIGN.bi_proveedor (
    id INTEGER PRIMARY KEY,
    razon_social VARCHAR(100) NOT NULL
);
PRINT 'Creada tabla Proveedor BI';

CREATE TABLE LOW_STRESS_DESIGN.bi_ciudad (
    codigo INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);
PRINT 'Creada tabla ciudad BI.';

CREATE TABLE LOW_STRESS_DESIGN.bi_tipo_habitacion (
    codigo INT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);
PRINT 'Creada tabla bi_tipo_habitacion.';

CREATE TABLE LOW_STRESS_DESIGN.bi_avion (
    identificador VARCHAR(50) NOT NULL PRIMARY KEY,
    modelo VARCHAR(50)
);
PRINT 'Creada tabla bi_avion.';

CREATE TABLE LOW_STRESS_DESIGN.bi_ruta_aerea (
    codigo INT PRIMARY KEY
);
PRINT 'Creada tabla bi_ruta_aerea.'

CREATE TABLE LOW_STRESS_DESIGN.bi_tipo_pasaje (
    id INT IDENTITY(0,1) PRIMARY KEY,
    descripcion VARCHAR(50)
);
PRINT 'Creada bi_tipo_pasaje.'

CREATE TABLE LOW_STRESS_DESIGN.fact_table_estadia (
    id_anio_y_mes INT NOT NULL,
    id_cliente INT NOT NULL,
    id_empresa INT NOT NULL,
    id_tipo_habitacion INT NOT NULL,
    precio_promedio_compra INT NOT NULL,
    precio_promedio_venta INT NOT NULL,
    cantidad_de_camas_vendidas INT NOT NULL,
    cantidad_de_habitaciones_vendidas INT NOT NULL,
    ganancias_realizadas INT NOT NULL,
    FOREIGN KEY (id_anio_y_mes) REFERENCES LOW_STRESS_DESIGN.bi_anio_y_mes (id),
    FOREIGN KEY (id_cliente) REFERENCES LOW_STRESS_DESIGN.bi_cliente (id),
    FOREIGN KEY (id_empresa) REFERENCES LOW_STRESS_DESIGN.bi_proveedor (id),
    FOREIGN KEY (id_tipo_habitacion) REFERENCES LOW_STRESS_DESIGN.bi_tipo_habitacion (codigo),
    PRIMARY KEY (id_anio_y_mes, id_cliente, id_empresa, id_tipo_habitacion)
);
PRINT 'Creada Fact Table de Estadias';

CREATE TABLE LOW_STRESS_DESIGN.fact_table_pasaje (
    id_anio_y_mes INT NOT NULL FOREIGN KEY REFERENCES LOW_STRESS_DESIGN.bi_anio_y_mes (id),
    id_cliente INT NOT NULL FOREIGN KEY REFERENCES LOW_STRESS_DESIGN.bi_cliente (id),
    id_empresa INT NOT NULL FOREIGN KEY REFERENCES LOW_STRESS_DESIGN.bi_proveedor (id),
    id_ciudad_orig INT NOT NULL FOREIGN KEY REFERENCES LOW_STRESS_DESIGN.bi_ciudad (codigo),
    id_ciudad_dest INT NOT NULL FOREIGN KEY REFERENCES LOW_STRESS_DESIGN.bi_ciudad (codigo),
    id_avion VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES LOW_STRESS_DESIGN.bi_avion (identificador),
    codigo_ruta_aerea INT NOT NULL FOREIGN KEY REFERENCES LOW_STRESS_DESIGN.bi_ruta_aerea (codigo),
    precio_promedio_compra INT NOT NULL,
    precio_promedio_venta INT NOT NULL,
    cantidad_de_pasajes_aereos_vendidos INT NOT NULL,
    ganancias_realizadas INT NOT NULL,
    PRIMARY KEY (id_anio_y_mes, id_cliente, id_empresa, id_ciudad_orig, id_ciudad_dest, id_avion, codigo_ruta_aerea)
);
PRINT 'Creada Fact Table de Pasajes';

PRINT 'Comienzo carga del modelo BI';

PRINT 'El mismo se compone de dos Fact tables con sus respectivas dimensiones';

INSERT INTO LOW_STRESS_DESIGN.bi_ciudad (codigo, nombre)
SELECT codigo, nombre FROM LOW_STRESS_DESIGN.ciudad;

PRINT 'Migradas ciudades al modelo BI';

INSERT INTO LOW_STRESS_DESIGN.bi_cliente (id, dni, apellido, nombre, email, fecha_nac, telefono)
SELECT id, dni, apellido, nombre, email, fecha_nac, telefono FROM LOW_STRESS_DESIGN.cliente;

PRINT 'Migrados clientes al modelo BI';

INSERT INTO LOW_STRESS_DESIGN.bi_proveedor (id, razon_social)
SELECT id, razon_social FROM LOW_STRESS_DESIGN.empresa;

PRINT 'Migrados proveedores al modelo BI';

INSERT INTO LOW_STRESS_DESIGN.bi_anio_y_mes (anio, mes)
SELECT DISTINCT YEAR(f.fecha), MONTH(f.fecha) FROM LOW_STRESS_DESIGN.factura f;

PRINT 'Migradas fechas con actividad al modelo BI';

INSERT INTO LOW_STRESS_DESIGN.bi_tipo_habitacion (codigo, descripcion)
SELECT codigo, descripcion
FROM LOW_STRESS_DESIGN.tipo_habitacion

PRINT 'Migrados tipos de habitaciones al modelo BI';

INSERT INTO LOW_STRESS_DESIGN.bi_avion (identificador, modelo)
SELECT identificador, modelo
FROM LOW_STRESS_DESIGN.avion

PRINT 'Migrados aviones al modelo BI';

INSERT INTO LOW_STRESS_DESIGN.bi_ruta_aerea (codigo)
SELECT DISTINCT codigo
FROM LOW_STRESS_DESIGN.ruta_aerea

PRINT 'Migradas rutas aereas al modelo BI';

INSERT INTO LOW_STRESS_DESIGN.bi_tipo_pasaje (descripcion)
SELECT DISTINCT tipo
FROM LOW_STRESS_DESIGN.butaca

PRINT 'Migradas tipos de pasaje al modelo BI';

INSERT INTO LOW_STRESS_DESIGN.fact_table_estadia (id_anio_y_mes, id_cliente, id_empresa, id_tipo_habitacion,cantidad_de_camas_vendidas, precio_promedio_compra, precio_promedio_venta, cantidad_de_habitaciones_vendidas, ganancias_realizadas)
SELECT
    aym.id,
    f.id_cliente,
    co.id_empresa,
    h.id_tipo_habitacion,
    SUM(
        CASE
            WHEN h.id_tipo_habitacion = 1001 THEN 1
            WHEN h.id_tipo_habitacion = 1002 THEN 2
            WHEN h.id_tipo_habitacion = 1003 THEN 3
            WHEN h.id_tipo_habitacion = 1004 THEN 4
            WHEN h.id_tipo_habitacion = 1005 THEN 1
        END
    ) 'Camas Vendidas',
    AVG(h.costo) 'Promedio de Compra',
    AVG(h.precio) 'Promedio de Venta',
    COUNT(*) 'Habitaciones Vendidas',
    (SUM(h.precio) - SUM(h.costo)) 'Ganancias Realizadas'
FROM LOW_STRESS_DESIGN.factura f
JOIN LOW_STRESS_DESIGN.estadia e ON (e.codigo = f.id_servicio)
JOIN LOW_STRESS_DESIGN.habitacion h ON (h.id_habitacion = e.id_habitacion)
JOIN LOW_STRESS_DESIGN.bi_anio_y_mes aym ON (aym.anio = YEAR(f.fecha) AND aym.mes = MONTH(f.fecha))
JOIN LOW_STRESS_DESIGN.servicio s ON (s.codigo = f.id_servicio)
JOIN LOW_STRESS_DESIGN.compra co ON (co.numero = s.id_compra)
GROUP BY aym.id, f.id_cliente, co.id_empresa, h.id_tipo_habitacion;

PRINT 'Llenado de Fact Table Estadia completo';

INSERT INTO LOW_STRESS_DESIGN.fact_table_pasaje (
	id_anio_y_mes,
	id_cliente,
	id_empresa,
	id_ciudad_orig,
	id_ciudad_dest,
	id_avion,
	codigo_ruta_aerea,
	precio_promedio_compra,
	precio_promedio_venta,
	cantidad_de_pasajes_aereos_vendidos,
	ganancias_realizadas)
SELECT
	aym.id,
	f.id_cliente,
	co.id_empresa,
	ra.id_ciudad_orig,
	ra.id_ciudad_dest,
	v.id_avion,
	ra.codigo,
	AVG(p.costo) 'precio_promedio_compra',
	AVG(p.precio) 'precio_promedio_venta',
	COUNT(*) 'cantidad_de_pasajes_aereos_vendidos',
	SUM(p.precio - p.costo) 'ganancias_realizadas'
FROM LOW_STRESS_DESIGN.pasaje p
JOIN LOW_STRESS_DESIGN.factura f ON f.id_servicio = p.codigo
JOIN LOW_STRESS_DESIGN.bi_anio_y_mes aym ON (aym.anio = YEAR(f.fecha) AND aym.mes = MONTH(f.fecha))
JOIN LOW_STRESS_DESIGN.servicio s ON (s.codigo = f.id_servicio)
JOIN LOW_STRESS_DESIGN.compra co ON (co.numero = s.id_compra)
JOIN LOW_STRESS_DESIGN.vuelo v ON v.codigo = p.id_vuelo
JOIN LOW_STRESS_DESIGN.ruta_aerea ra ON v.id_ruta_aerea = ra.id
GROUP BY aym.id, f.id_cliente, co.id_empresa, ra.id_ciudad_orig, ra.id_ciudad_dest, v.id_avion, ra.codigo;

PRINT 'Llenado de Fact Table Pasaje completo';













