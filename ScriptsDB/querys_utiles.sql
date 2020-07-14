--Drop de todas las tablas, sps y schema
DROP TABLE LA_EMPRESA.pasaje_butaca
DROP TABLE LA_EMPRESA.pasaje
DROP TABLE LA_EMPRESA.vuelo
DROP TABLE LA_EMPRESA.ruta_aerea
DROP TABLE LA_EMPRESA.butaca
DROP TABLE LA_EMPRESA.avion
DROP TABLE LA_EMPRESA.factura
DROP TABLE LA_EMPRESA.estadia
DROP TABLE LA_EMPRESA.habitacion
DROP TABLE LA_EMPRESA.hotel
DROP TABLE LA_EMPRESA.servicio
DROP TABLE LA_EMPRESA.compra
DROP TABLE LA_EMPRESA.tipo_habitacion
DROP TABLE LA_EMPRESA.cliente
DROP TABLE LA_EMPRESA.ciudad
DROP TABLE LA_EMPRESA.sucursal
DROP TABLE LA_EMPRESA.empresa

DROP PROCEDURE LA_EMPRESA.SP_MIGRATION_SCHEMA
DROP SCHEMA LA_EMPRESA

--Get column length
SELECT MAX(LEN(BUTACA_TIPO)) FROM gd_esquema.Maestra;


--DROP tablas de BI

DROP TABLE LA_EMPRESA.fact_table_pasaje;
DROP TABLE LA_EMPRESA.fact_table_estadia;
DROP TABLE LA_EMPRESA.bi_tipo_pasaje;
DROP TABLE LA_EMPRESA.bi_ruta_aerea;
DROP TABLE LA_EMPRESA.bi_avion;
DROP TABLE LA_EMPRESA.bi_tipo_habitacion;
DROP TABLE LA_EMPRESA.bi_ciudad;
DROP TABLE LA_EMPRESA.bi_proveedor;
DROP TABLE LA_EMPRESA.bi_cliente;
DROP TABLE LA_EMPRESA.bi_anio_y_mes;