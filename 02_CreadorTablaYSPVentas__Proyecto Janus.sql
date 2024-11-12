-------------------------------<CREACION DE TABLAS Y STORED PROCEDURES VENTAS>-----------------------------------------

/* 


-------------------<Introduccion>------------------------------------

-->En este script estara el codigo para crear las tablas y SP relacionados a las ventas Registradas. Es importante aclarar
    que para su correcto funcionamiento primero debe haber ejecutado el script "01_CreadorTablasYSP" en su totalidad. 


-->Cumplimiento de consigna: Entrega 3
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7: Proyecto Janus


	DNI			DIRECTORES DEL PROYECTO
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE


--<Indice>--

+TABLAS
+SP VentaRegistrada
+SP detalleVenta


*/

---------------------------------------------<TABLAS>------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com2900G07')
BEGIN
    print('Debe ejecutar el script de creacion de tablas y sq para poder usar este script')
END;

use Com2900G07
go


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ventaRegistrada')
BEGIN
	CREATE TABLE level2.ventaRegistrada(idVenta INT PRIMARY KEY IDENTITY(1,1),
										iDFactura VARCHAR(50),
										tipoFactura CHAR(1),
										ciudad VARCHAR(40),
										tipoCliente CHAR(6),
										genero VARCHAR(6) CHECK(genero = 'Mujer' or genero = 'Hombre'),
										producto VARCHAR(100),
										precioUnitario DECIMAL(10,2),
										cantidad INT CHECK (cantidad > 0),
										fechaHora DATETIME,
										medioPago VARCHAR(25) CHECK(medioPago ='Credit Card' or medioPago ='Cash' or medioPago ='Ewallet'), 
										identificadorPago VARCHAR(50),
										legajo_Id INT REFERENCES level2.empleado(legajo_Id),
										sucursal VARCHAR(20)
										)
END
GO

DROP table level2.ventaRegistrada

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'detalleVenta')
BEGIN
	CREATE TABLE level2.detalleVenta(	iDFactura VARCHAR(50) PRIMARY KEY,
										tipoFactura CHAR(1),
										ciudad VARCHAR(40),
										tipoCliente CHAR(6),
										medioPago VARCHAR(25) CHECK(medioPago ='Credit Card' or medioPago ='Cash' or medioPago ='Ewallet'), 
										legajo_Id INT REFERENCES level2.empleado(legajo_Id),
										sucursal VARCHAR(20),
										total DECIMAL(10, 2),
										cantidadCompras INT
										)
END
GO

-----------------------<VENTA REGISTRADA>----------------------------------------



--Funcion para buscar el precio de un producto. En caso de no encontrar el producto devuelve 0.

CREATE OR ALTER FUNCTION level2.buscarPrecioProducto (@producto VARCHAR(100)) RETURNS DECIMAL (10,2)
BEGIN
DECLARE @precio DECIMAL(10,2) = 0

SET @precio = (SELECT precio FROM level1.producto WHERE nombreProducto = @producto)

RETURN @precio
END
GO


CREATE OR ALTER PROCEDURE level2.insertarUnaVentaRegistrada @idFactura VARCHAR(50), @tipoFactura CHAR(1),  @sucursal VARCHAR(20), @tipoCliente CHAR(6), @genero VARCHAR(6), @producto VARCHAR(100), @cantidad INT,
										 @fechaHora DATETIME, @medioPago VARCHAR(25), @identificadorPago VARCHAR(50), @legajo_Id INT AS

BEGIN

--PRIMERO VALIDO SI LA ID FACTURA Y EL IDENTIFICADOR PAGO ES UNICA 

--SEGUNDO VALIDO SI LA SUCURSAL, EL EMPLEADO, EL MEDIO DE PAGO, GENERO Y EL PRODUCTO ESTAN REGISTRADOS EN LA BASE DE DATOS, Y DE PASO LA CANTIDAD NO SEA NEGATIVA 

		if((SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal = @sucursal) IS NOT NULL and (SELECT idProducto FROM level1.producto WHERE nombreProducto = @producto) IS NOT NULL and 
			(@medioPago ='Credit Card' or @medioPago ='Cash' or @medioPago ='Ewallet') and (@genero = 'Mujer' or @genero = 'Hombre') and 
			(SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NOT NULL and @cantidad > 0)
			BEGIN

--TERCERO CALCULO Y BUSCO LOS VALORES FALTANTES

			DECLARE @precioUnitario DECIMAL (10,2) = level2.buscarPrecioProducto(@producto)

			DECLARE @ciudad VARCHAR (40) = (SELECT ciudad FROM level1.sucursal WHERE nombreSucursal = @sucursal)
--INSERTO

			INSERT INTO level2.ventaRegistrada (iDFactura,tipoFactura, ciudad,tipoCliente, genero,producto,precioUnitario, cantidad, fechaHora, medioPago, identificadorPago, legajo_Id, sucursal)

			VALUES (@idFactura, @tipoFactura, @ciudad, @tipoCliente, @genero, @producto, @precioUnitario, @cantidad, @fechaHora, @medioPago,
					@identificadorPago, @legajo_Id, @sucursal)
			EXEC level2.atiendeDetalleVenta @idFactura
			print('Se ha registrado la factura exitosamente')
			END

		else 
			print('Revise si los datos son correctos dado que, o no existe la sucursal, producto o empleado, o el medio de pago o la cantidad es invalida')



END
go

CREATE OR ALTER PROCEDURE level2.eliminarVentaRegistrada @idVenta INT AS
BEGIN

DELETE level2.ventaRegistrada WHERE idVenta = @idVenta


END
go

-------------------------------------------------------<DETALLE VENTA>-------------------------------------------------------------------

CREATE OR ALTER PROCEDURE level2.atiendeDetalleVenta @iDFactura VARCHAR(25) AS
BEGIN
    DECLARE @total DECIMAL(10, 2);

    -- Calcular el nuevo total de la factura sumando todos los productos de la factura actual
    SET @total = (SELECT SUM(cantidad * precioUnitario) FROM level2.ventaRegistrada WHERE iDFactura = @iDFactura)

	SET @total = @total + (@total * 0.24)--SE LE AGREGA EL IVA

    IF EXISTS (SELECT 1 FROM level2.detalleVenta WHERE idFactura = @idFactura)	--Si existe actualizo el precio
    BEGIN
        UPDATE detalleVenta
        SET total = @total,
		cantidadCompras = (cantidadCompras + 1)
        WHERE idFactura = @idFactura;
    END
    ELSE	--Si no existe, creo el nuevo
    	BEGIN

		DECLARE @tipoFactura char(1) = (SELECT tipoFactura FROM level2.ventaRegistrada WHERE idFactura = @iDFactura)
		DECLARE @ciudad VARCHAR(40) = (SELECT ciudad FROM level2.ventaRegistrada WHERE idFactura = @iDFactura)
		DECLARE @tipoCliente CHAR(6) = (SELECT tipoCliente FROM level2.ventaRegistrada WHERE idFactura = @iDFactura)
		DECLARE @medioPago VARCHAR(25) = (SELECT medioPago FROM level2.ventaRegistrada WHERE idFactura = @iDFactura)
		DECLARE @legajo_Id INT = (SELECT legajo_Id FROM level2.ventaRegistrada WHERE idFactura = @iDFactura)
		DECLARE @sucursal VARCHAR(20) = (SELECT sucursal FROM level2.ventaRegistrada WHERE idFactura = @iDFactura)
	
        INSERT INTO level2.detalleVenta (idFactura, tipoFactura, ciudad, tipoCliente, medioPago, legajo_Id, sucursal, total, cantidadCompras)
        VALUES (@idFactura, @tipoFactura, @ciudad, @tipoCliente, @medioPago, @legajo_Id, @sucursal, @total, 1);
    END
END;

go

CREATE OR ALTER PROCEDURE level2.eliminarDetalleVenta @idFactura VARCHAR(25) AS
BEGIN

	DELETE FROM level2.detalleVenta WHERE idFactura = @idFactura


END
go

