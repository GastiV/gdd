USE [GD1C2020]
GO
--CREACION DE SCHEMA
CREATE SCHEMA [LA_EMPRESA] --AUTHORIZATION [gd] --tengo que crear un usuario? 
GO

CREATE PROCEDURE LA_EMPRESA.SP_MIGRATION_SCHEMA
AS
	
	--CREACION DE TABLAS
	PRINT 'Comienza la creación de tablas.'

	CREATE TABLE LA_EMPRESA.empresa (
		id INTEGER IDENTITY(0,1) PRIMARY KEY,
		razon_social VARCHAR(100) NOT NULL
	);
	PRINT 'Creada tabla empresa.'

	CREATE TABLE LA_EMPRESA.sucursal(
		id INTEGER IDENTITY(0,1) PRIMARY KEY,
		dir VARCHAR(50) NOT NULL,
		mail VARCHAR(50) NOT NULL,
		telefono INTEGER NOT NULL
	);
	PRINT 'Creada tabla sucursal.'

	CREATE TABLE LA_EMPRESA.ciudad (
		codigo INT IDENTITY(0,1) PRIMARY KEY, --Por alguna razon arranca en 0??
		nombre VARCHAR(50) NOT NULL
	);
	PRINT 'Creada tabla ciudad.'

	--TODO: Actualizar id cliente en el DER
	--Dos clientes con el mismo DNI
	--https://groups.google.com/forum/#!topic/gestiondedatos/L9DFvV4DgmI thread sobre el asunto
	--SELECT * FROM gd_esquema.Maestra WHERE CLIENTE_DNI = '1353465'
	--todos tienen el mail repetido



	CREATE TABLE LA_EMPRESA.cliente (
		id INTEGER IDENTITY(0,1) PRIMARY KEY,
		dni INTEGER NOT NULL,
		apellido VARCHAR(50) NOT NULL,
		nombre VARCHAR(50) NOT NULL,
		fecha_nac DATETIME NOT NULL,
		email VARCHAR(50) NOT NULL,
		telefono INTEGER NOT NULL
	);
	PRINT 'Creada tabla cliente.'

	CREATE TABLE LA_EMPRESA.tipo_habitacion (
		codigo INT PRIMARY KEY,
		descripcion VARCHAR(50) NOT NULL
	);
	PRINT 'Creada tabla tipo_habitacion.'

	CREATE TABLE LA_EMPRESA.compra(
		numero INT PRIMARY KEY,
		id_empresa int NOT NULL,
		fecha DATETIME NOT NULL,
		FOREIGN KEY (id_empresa) REFERENCES LA_EMPRESA.empresa (id)
	);
	PRINT 'Creada tabla compra.'

	CREATE TABLE LA_EMPRESA.servicio(
		codigo INT PRIMARY KEY,
		id_compra int NOT NULL,
		FOREIGN KEY (id_compra) REFERENCES LA_EMPRESA.compra (numero)
	);
	PRINT 'Creada tabla servicio.'

	CREATE TABLE LA_EMPRESA.hotel(
		id_hotel INT IDENTITY(0,1) PRIMARY KEY,
		id_empresa int,
		calle VARCHAR(50),
		nro_calle int,
		cantidad_estrellas int,
		FOREIGN KEY (id_empresa) REFERENCES LA_EMPRESA.empresa (id)
	);
	PRINT 'Creada tabla hotel.'

	CREATE TABLE LA_EMPRESA.habitacion(
		id_habitacion INTEGER IDENTITY(0,1) PRIMARY KEY,
		id_hotel INTEGER NOT NULL,
		id_tipo_habitacion INTEGER NOT NULL,
		numero INTEGER NOT NULL,
		piso INTEGER NOT NULL,
		frente VARCHAR(5) NOT NULL,
		costo INTEGER NOT NULL,
		precio INTEGER NOT NULL,
		FOREIGN KEY (id_hotel) REFERENCES LA_EMPRESA.hotel (id_hotel),
		FOREIGN KEY (id_tipo_habitacion) REFERENCES LA_EMPRESA.tipo_habitacion (codigo)
	);
	PRINT 'Creada tabla habitacion.'

	CREATE TABLE LA_EMPRESA.estadia(
		codigo INTEGER PRIMARY KEY,
		id_habitacion INTEGER NOT NULL,
		fecha_ini DATETIME NOT NULL,
		cantidad_noches INTEGER NOT NULL,
		FOREIGN KEY (id_habitacion) REFERENCES LA_EMPRESA.habitacion (id_habitacion)
	);

	PRINT 'Creada tabla estadia.'

	CREATE TABLE LA_EMPRESA.factura(
		nro INTEGER PRIMARY KEY,
		id_servicio INTEGER NOT NULL,
		id_cliente INTEGER NOT NULL,
		id_sucursal INTEGER NOT NULL,
		FOREIGN KEY (id_servicio) REFERENCES LA_EMPRESA.servicio (codigo),
		FOREIGN KEY (id_cliente) REFERENCES LA_EMPRESA.cliente (id),
		FOREIGN KEY (id_sucursal) REFERENCES LA_EMPRESA.sucursal (id)
	);
	PRINT 'Creada tabla factura.'

	CREATE TABLE LA_EMPRESA.avion (
		identificador VARCHAR(50) NOT NULL PRIMARY KEY,
		id_empresa INT NOT NULL FOREIGN KEY REFERENCES LA_EMPRESA.empresa(id),
		modelo VARCHAR(50)
	);
	PRINT 'Creada tabla avion.'


	--rename en DER "id_butaca" a "id"
	--relacion de butaca a pasaje es de uno a muchos opcional (CORREGIR)
	CREATE TABLE LA_EMPRESA.butaca (
		id INT IDENTITY(0,1) PRIMARY KEY,
		id_avion VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES LA_EMPRESA.avion(identificador),
		numero INT NOT NULL,
		tipo VARCHAR(50)
	);
	PRINT 'Creada tabla butaca.'


	-- El campo id sirve para identificar a la ruta aerea direccionada
	-- El campo codigo sirve para identificar a la ruta aerea sin importar direccionamiento
	CREATE TABLE LA_EMPRESA.ruta_aerea (
		id INT IDENTITY(0,1) PRIMARY KEY,
		codigo INT NOT NULL,
		id_ciudad_orig INT NOT NULL FOREIGN KEY REFERENCES LA_EMPRESA.ciudad(codigo),
		id_ciudad_dest INT NOT NULL FOREIGN KEY REFERENCES LA_EMPRESA.ciudad(codigo)
	);
	PRINT 'Creada tabla ruta_aerea.'

	--corregir DER "fecha_saluda"
	CREATE TABLE LA_EMPRESA.vuelo (
		codigo INT NOT NULL PRIMARY KEY,
		id_avion VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES LA_EMPRESA.avion(identificador),
		id_ruta_aerea INT NOT NULL FOREIGN KEY REFERENCES LA_EMPRESA.ruta_aerea(id),
		fecha_salida DATETIME,
		fecha_llegada DATETIME
	);
	PRINT 'Creada tabla vuelo.'

	CREATE TABLE LA_EMPRESA.pasaje (
		codigo INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES LA_EMPRESA.servicio(codigo),
		id_butaca INT NOT NULL FOREIGN KEY REFERENCES LA_EMPRESA.butaca(id),
		id_vuelo INT NOT NULL FOREIGN KEY REFERENCES LA_EMPRESA.vuelo(codigo),
		costo DECIMAL(18,2) NOT NULL,
		precio DECIMAL(18,2) NOT NULL,
		fecha_compra DATETIME NOT NULL
	);
	PRINT 'Creada tabla pasaje.'
	--PRINT 'Creada tabla .'
GO
EXECUTE LA_EMPRESA.SP_MIGRATION_SCHEMA
PRINT 'Creadas tablas del esquema'
GO



--------------------------- MIGRACION DE DATOS ---------------------------

INSERT INTO LA_EMPRESA.empresa (razon_social)
SELECT DISTINCT  EMPRESA_RAZON_SOCIAL
FROM gd_esquema.Maestra M 
WHERE EMPRESA_RAZON_SOCIAL IS NOT NULL ORDER BY 1

GO
PRINT 'Empresas migradas'
GO

--Todas las sucursales
INSERT INTO LA_EMPRESA.sucursal (dir, mail, telefono)
select distinct SUCURSAL_DIR, SUCURSAL_MAIL, SUCURSAL_TELEFONO
FROM gd_esquema.Maestra
WHERE (SUCURSAL_DIR is not null or SUCURSAL_MAIL is not null or SUCURSAL_TELEFONO is not null);
GO
PRINT 'Sucursales migradas'
GO

INSERT INTO LA_EMPRESA.ciudad (nombre)
SELECT DISTINCT m.RUTA_AEREA_CIU_DEST as CIUDADES
FROM gd_esquema.Maestra m 
WHERE m.RUTA_AEREA_CIU_DEST is not null union
SELECT distinct m.RUTA_AEREA_CIU_ORIG as CIUDADES
FROM gd_esquema.Maestra m
WHERE m.RUTA_AEREA_CIU_ORIG is not null

GO
PRINT 'Ciudades migradas'
GO


--Todos los clientes

INSERT INTO LA_EMPRESA.cliente (nombre, apellido, dni, email, telefono, fecha_nac)
SELECT distinct m.CLIENTE_NOMBRE, m.CLIENTE_APELLIDO, CAST(m.CLIENTE_DNI as INTEGER) as DNI, m.CLIENTE_MAIL, CAST(m.CLIENTE_TELEFONO as INTEGER) as TELEFONO, CAST(m.CLIENTE_FECHA_NAC as DATETIME)
FROM gd_esquema.Maestra m
WHERE m.CLIENTE_DNI is not null order by m.CLIENTE_NOMBRE, m.CLIENTE_APELLIDO;
PRINT 'Clientes migrados'

INSERT INTO LA_EMPRESA.tipo_habitacion (codigo, descripcion)
SELECT DISTINCT TIPO_HABITACION_CODIGO, TIPO_HABITACION_DESC 
FROM gd_esquema.Maestra 
WHERE TIPO_HABITACION_CODIGO is not null or TIPO_HABITACION_DESC is not null;
PRINT 'Tipo de habitaciones migradas'

-- MIGRACION HOTEL

INSERT INTO LA_EMPRESA.hotel (id_empresa, calle, cantidad_estrellas, nro_calle)
SELECT DISTINCT E.id, M.HOTEL_CALLE, M.HOTEL_CANTIDAD_ESTRELLAS, M.HOTEL_NRO_CALLE
FROM LA_EMPRESA.empresa E
JOIN gd_esquema.Maestra M ON M.EMPRESA_RAZON_SOCIAL = E.razon_social
WHERE M.HOTEL_CALLE IS NOT NULL ORDER BY E.id

PRINT 'Hoteles migrados'

INSERT INTO LA_EMPRESA.habitacion (id_hotel, id_tipo_habitacion, numero, piso, precio, frente, costo)
SELECT DISTINCT H.id_hotel ,TA.codigo, HABITACION_NUMERO, HABITACION_PISO,HABITACION_PRECIO, CAST(HABITACION_FRENTE AS varchar) ,HABITACION_COSTO
FROM LA_EMPRESA.hotel H
JOIN gd_esquema.Maestra M ON H.calle = M.HOTEL_CALLE
JOIN LA_EMPRESA.tipo_habitacion TA ON M.TIPO_HABITACION_DESC = TA.descripcion
WHERE HABITACION_COSTO IS NOT NULL;

PRINT 'Tipo de habitaciones migradas'

INSERT INTO LA_EMPRESA.avion (identificador, id_empresa, modelo)
SELECT DISTINCT m.AVION_IDENTIFICADOR, e.id, m.AVION_MODELO
FROM gd_esquema.Maestra as m
         JOIN LA_EMPRESA.empresa as e ON m.EMPRESA_RAZON_SOCIAL = e.razon_social
WHERE m.AVION_IDENTIFICADOR IS NOT NULL


INSERT INTO LA_EMPRESA.ruta_aerea (codigo, id_ciudad_orig, id_ciudad_dest)
SELECT DISTINCT m.RUTA_AEREA_CODIGO, c1.codigo, c2.codigo
FROM gd_esquema.Maestra as m
         JOIN LA_EMPRESA.ciudad as c1 ON m.RUTA_AEREA_CIU_ORIG = c1.nombre
         JOIN LA_EMPRESA.ciudad as c2 ON m.RUTA_AEREA_CIU_DEST = c2.nombre

INSERT INTO LA_EMPRESA.vuelo (codigo, id_avion, id_ruta_aerea, fecha_salida, fecha_llegada)
SELECT DISTINCT m.VUELO_CODIGO, m.AVION_IDENTIFICADOR, ra.id, m.VUELO_FECHA_SALUDA, m.VUELO_FECHA_LLEGADA
FROM LA_EMPRESA.ruta_aerea as ra
         JOIN LA_EMPRESA.ciudad as c1 ON ra.id_ciudad_orig = c1.codigo
         JOIN LA_EMPRESA.ciudad as c2 ON ra.id_ciudad_dest = c2.codigo
         JOIN gd_esquema.Maestra as m ON (m.RUTA_AEREA_CODIGO = ra.codigo AND m.RUTA_AEREA_CIU_ORIG = c1.nombre AND m.RUTA_AEREA_CIU_DEST = c2.nombre)


INSERT INTO LA_EMPRESA.butaca (id_avion, numero, tipo)
SELECT DISTINCT m.AVION_IDENTIFICADOR, m.BUTACA_NUMERO, m.BUTACA_TIPO
FROM gd_esquema.Maestra as m
where m.AVION_IDENTIFICADOR is not null AND m.BUTACA_NUMERO is not null
