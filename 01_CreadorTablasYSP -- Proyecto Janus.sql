-------------------------------<CREACION DE TABLAS Y STORED PROCEDURES BASICOS>-----------------------------------------

/* 


-------------------<Introduccion>------------------------------------

-->En este script estara el codigo para crear la base de datos con las tablas iniciales y los sp basicos para hacer 
   funcionar el proyecto. Debe ejecutar los SP en orden con los que estan puestos. 


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
+SP Sucursal
+SP Cargo
+SP Empleado
+SP Catalogo
+SP Productos
+SP MedioPago
+SP VentaRegistrada
+SP DetalleVenta


*/

---------------------------------------------<TABLAS>------------------------------------------------

drop database Com2900G07

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com2900G07')
BEGIN
    CREATE DATABASE Com2900G07;
END;
go
USE Com2900G07
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'level1')
BEGIN
    EXEC('CREATE SCHEMA level1');
END
go
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'level2')
BEGIN
    EXEC('CREATE SCHEMA level2');
END
go


---------------------------------------------------------<CREACION DE TABLAS>-----------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'sucursal')
BEGIN
	CREATE TABLE level1.sucursal(	idSucursal INT PRIMARY KEY IDENTITY(1,1),
									ciudad VARCHAR(40) NOT NULL,
									nombreSucursal VARCHAR (40) NOT NULL UNIQUE,
									direccion VARCHAR(100) NOT NULL,
									telefono VARCHAR(10) NOT NULL)
END					
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'cargo')
BEGIN

	CREATE TABLE level2.cargo(	idCargo INT PRIMARY KEY,
								descripcionCargo VARCHAR (25) NOT NULL UNIQUE)
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'empleado')
BEGIN
CREATE TABLE level2.empleado(		legajo_Id INT PRIMARY KEY IDENTITY(257020,1),  
					nombre VARCHAR(50) NOT NULL,
					apellido VARCHAR(50) NOT NULL,
					dni INT UNIQUE NOT NULL CHECK (dni >= 10000000 and dni <= 99999999),
					direccion VARCHAR(100),
					emailEmpresa VARCHAR(100),
					emailPersonal VARCHAR(100),
					cuil VARCHAR(13),
					cargo VARCHAR(25) REFERENCES level2.cargo(descripcionCargo),				--	<-- FK a la tabla cargo
					sucursal VARCHAR(40) REFERENCES level1.sucursal (nombreSucursal),		--  <-- FK a la tabla sucursal
					turno VARCHAR(4) NOT NULL CHECK (turno = 'TM' or turno = 'TT' or turno='TN' or turno='FULL'),
					estado char(10) CHECK (estado = '1' or estado = '0'))
END
GO




IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'producto')
BEGIN
	CREATE TABLE level1.producto(			idProducto INT PRIMARY KEY IDENTITY(1,1),	 	
							Categoria VARCHAR(50) NOT NULL,			
							nombreProducto VARCHAR (100) NOT NULL,			
							precio DECIMAL(10,2) NOT NULL,
							ReferenciaUnidad VARCHAR(30))			
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ventaRegistrada')
BEGIN
	CREATE TABLE level2.ventaRegistrada(idVenta INT PRIMARY KEY IDENTITY(1,1),
										iDFactura VARCHAR(50),
										tipoFactura CHAR(1),
										ciudad VARCHAR(40),
										tipoCliente CHAR(6),
										genero VARCHAR(6),
										fechaHora DATETIME,
										medioPago VARCHAR(25) CHECK(medioPago ='Credit Card' or medioPago ='Cash' or medioPago ='Ewallet'),
										Empleado INT REFERENCES level2.empleado(legajo_Id),
										MontoTotal DECIMAL(10,2) DEFAULT 0,
										identificadorPago VARCHAR(50)
)
										
END
GO

DROP table level2.ventaRegistrada

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'detalleVenta')
BEGIN
	CREATE TABLE level2.detalleVenta(				
						iDFactura VARCHAR(50) PRIMARY KEY,
						NombreProducto VARCHAR(100),
						Cantidad INT,
						PrecioUnitario DECIMAL(10,2)
)
END
GO





----------------------------------<SUCURSAL>--------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE level1.insertarUnSucursal @ciudad VARCHAR(25), @nombreSucursal VARCHAR(40), @direccion VARCHAR(100), @telefono VARCHAR(10) AS
BEGIN
    if (@ciudad IS NOT NULL and @ciudad != '' and @nombreSucursal IS NOT NULL and @nombreSucursal != '' and @direccion IS NOT NULL and @direccion != '' and @telefono IS NOT NULL and @telefono != '' )
	BEGIN

		if((SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal=@nombreSucursal) IS NULL) 
		BEGIN
        INSERT INTO level1.sucursal (ciudad, nombreSucursal, direccion, telefono) 
        VALUES (@ciudad, @nombreSucursal, @direccion, @telefono)
        PRINT ('Valores insertados correctamente en la tabla: Sucursal')
		END
		else
		print('Sucursal ya existente')
    END
    else
    BEGIN

        PRINT ('No se puede insertar a la tabla debido a que falta uno o más valores, o los valores superan el límite permitido.')

    END
END
GO



CREATE OR ALTER PROCEDURE level1.modificarSucursal  @idSucursal INT, @ciudad VARCHAR(25), @nombreSucursal VARCHAR(40), @direccion VARCHAR(100), @telefono VARCHAR(10) AS

	BEGIN
	if (SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal = @nombreSucursal) IS NOT NULL
		BEGIN

		if (@ciudad IS NOT NULL and @ciudad != '' and @nombreSucursal IS NOT NULL and @nombreSucursal != '' and @direccion IS NOT NULL and @direccion != '' and @telefono IS NOT NULL and @telefono != '' )
			BEGIN

			UPDATE level1.sucursal
			SET
			ciudad = @ciudad,
			nombreSucursal = @nombreSucursal,
			direccion = @direccion,
			telefono = @telefono
			WHERE @idSucursal = idSucursal

			END
		else
			PRINT ('No se puede actualizar valores vacios.')

		END
	else
		PRINT ('No se ha encontrado la sucursal que se quiere modificar')

	END
GO


CREATE OR ALTER PROCEDURE level1.borrarSucursal @nombreSucursal VARCHAR(50) AS
BEGIN
	if (SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal = @nombreSucursal) IS NOT NULL
	BEGIN
		DELETE FROM level2.empleado WHERE sucursal = @nombreSucursal
		DELETE FROM level1.sucursal WHERE nombreSucursal = @nombreSucursal
		PRINT ('La sucursal y sus empleados fueron eliminadados con exito.')

	END
	else
		print('No se ha encontrado la sucursal solicitada.')

END
GO




------------------------------------------------<CARGO>---------------------------------------------------------------------

CREATE OR ALTER PROCEDURE level2.insertarCargo  @idCargo INT, @descripcionCargo VARCHAR(25) AS
BEGIN

	if (SELECT descripcionCargo FROM level2.Cargo WHERE descripcionCargo = @descripcionCargo) IS NULL and (SELECT idCargo FROM level2.cargo WHERE idCargo = @idCargo) IS NULL
		BEGIN

		INSERT INTO level2.cargo (idCargo, descripcionCargo)
		VALUES (@idCargo, @descripcionCargo)
		print('Se ha creado el cargo correctamente')
		END
	
	else 
		print('Ya existe el cargo o el numero de id que quiere crear')

END
GO

EXEC level2.insertarCargo 1, 'Supervisor'
GO
EXEC level2.insertarCargo 2, 'Cajero'
GO
EXEC level2.insertarCargo 3, 'Gerente de sucursal'
GO



CREATE OR ALTER PROCEDURE level2.borrarCargo @idCargo INT AS
BEGIN 
	if (SELECT idCargo FROM level2.cargo WHERE idCargo=@idCargo) IS NOT NULL
		BEGIN
		DELETE FROM level2.cargo WHERE idCargo = @idCargo
		print('Se ha eliminado el cargo correctamente')
		END
	else
		print('No existe el cargo que quiere eliminar')

END
GO


------------------------------------------------<EMPLEADO>------------------------------------------------------------------

CREATE OR ALTER PROCEDURE level2.insertarUnEmpleado @legajo_Id INT, @nombre VARCHAR(25), @apellido VARCHAR(50), @dni INT, @direccion VARCHAR(100),
	    			@emailEmpresa VARCHAR(100), @emailPersonal VARCHAR(100) , @cuil VARCHAR(13), @idCargo VARCHAR(25), @idSucursal VARCHAR(40), @turno VARCHAR(4) AS

    BEGIN

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NULL)	--VALIDO EL LEGAJO SEA DE 257
		BEGIN

		if (SELECT legajo_Id FROM level2.empleado WHERE dni = @dni) IS NULL and (@dni >=10000000 and @dni <= 99999999)  --DVALIDO DNI ACEPTABLE Y NO REPETIBLE
			BEGIN

				--VALIDO QUE EXISTA EL CARGO Y LA SUCURSAL
			if(SELECT idCargo FROM level2.cargo WHERE descripcionCargo = @idCargo) IS NOT NULL AND (SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal = @idSucursal) IS NOT NULL
				BEGIN

				INSERT INTO  level2.empleado (legajo_Id, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno, estado) 
				VALUES (@legajo_Id, @nombre, @apellido, @dni, @direccion, @emailEmpresa, @emailPersonal, @cuil, @idCargo, @idSucursal, @turno, '1');
				print ('Valores insertados correctamente en la tabla: Empleado.');
				END
			else
				print('El valor de idSucursal y/o idCargo no existe')
			END
		else
		print('No se puede insertar el empleado a la tabla debido a que ya existe un empleado con su dni o el dni tiene un valor incorrecto.');
		END
	else
		print('No se puede insertar el empleado a la tabla debido a que ya existe un empleado con su legajo o el legajo tiene un valor incorrecto.');
    END
GO




CREATE OR ALTER PROCEDURE level2.modificarEmpleado @legajo_Id INT, @nombre VARCHAR(25), @apellido VARCHAR(50), @direccion VARCHAR(100),
	    			@emailEmpresa VARCHAR(100), @emailPersonal VARCHAR(100) , @cuil VARCHAR(13), @idCargo VARCHAR(25), @idSucursal VARCHAR(50), @turno VARCHAR(4) AS
BEGIN

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NOT NULL
	BEGIN

		if(SELECT idCargo FROM level2.cargo WHERE descripcionCargo = @idCargo) IS NOT NULL AND (SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal = @idSucursal) IS NOT NULL
		BEGIN
		UPDATE level2.empleado
		SET
		nombre = @nombre, 
		apellido = @apellido,
		direccion = @direccion, 
		emailEmpresa = @emailEmpresa, 
		emailPersonal = @emailPersonal, 
		cuil = @cuil,
		cargo = @idCargo,
		sucursal = @idSucursal,
		turno = @turno
		WHERE legajo_Id = @legajo_Id
		PRINT('Empleado actualizado.')
		END
		else
			print('Valor del idSucursal o idCargo no existe')

	END
	else
		PRINT('No se puede actualizar un empleado que no exista en la tabla.')
END
GO



CREATE OR ALTER PROCEDURE level2.borrarEmpleado @legajo_Id INT AS
BEGIN

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NOT NULL
	BEGIN

		UPDATE
		level2.empleado
		SET
		estado = '0'
		WHERE legajo_Id = @legajo_Id
		print ('El empleado fue eliminado con exito.')
	END

	else
		print('No se ha encontrado al empleado.')

END
GO

CREATE OR ALTER PROCEDURE level2.reactivarEmpleado @legajo_Id INT AS
BEGIN

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NOT NULL
	BEGIN

		UPDATE
		level2.empleado
		SET
		estado = '1'
		WHERE legajo_Id = @legajo_Id
		print ('El empleado fue reactivado.')
	END

	else
		print('No se ha encontrado al empleado.')

END
GO
----------------------------------------------------<PRODUCTOS>------------------------------------------------------------


CREATE OR ALTER PROCEDURE level1.insertarUnProducto   @nombreProducto VARCHAR(100), @Categoria VARCHAR(50), @precio DECIMAL(10,2), @ReferenciaUnidad VARCHAR(30) AS

    BEGIN
	--Verifico precio, que el producto no exista
	if (@precio >= 0) and (@nombreProducto IS NOT NULL and @nombreProducto != '' and (SELECT idProducto FROM level1.producto WHERE nombreProducto = @nombreProducto) IS NULL)
 		BEGIN

		INSERT INTO level1.producto (nombreProducto, Categoria, precio, ReferenciaUnidad)
		VALUES (@nombreProducto, @Categoria, @precio, @ReferenciaUnidad)
		print ('Producto insertado exitosamente')
		END

	else
		print('No se puede insertar el producto dado que los datos a insertar son erroneos.')
    END
GO


CREATE OR ALTER PROCEDURE level1.modificarProducto @idProducto INT, @Categoria VARCHAR(40), @precio DECIMAL(10,2) AS
BEGIN
--Veridico que el nombre del producto exista
	if (SELECT idProducto FROM level1.producto WHERE idProducto = @idProducto) IS NOT NULL
		BEGIN
		--Verifico que el precio no sea menor a 1
		if (@precio >= 0)
			BEGIN
			UPDATE level1.producto
			SET
			precio = @precio,
			Categoria = @Categoria
			WHERE idProducto = @idProducto
			print('Se ha actualizado el producto exitosamente')
			END
		else
			print('El precio no es aceptable')
		END
	else
		print('El producto a actualizar no se encuentra en la tabla')

END
GO



CREATE OR ALTER PROCEDURE level1.borrarProducto @idProducto INT AS
BEGIN
	if (SELECT idProducto FROM level1.producto WHERE idProducto = @idProducto) IS NOT NULL
	BEGIN

		DELETE FROM level1.producto WHERE idProducto = @idProducto
		print ('El producto fue eliminado con exito.');
	END
	else
		print('No se ha encontrado el producto.');

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
	DECLARE @cantidad int = (SELECT SUM(cantidad) FROM level2.ventaRegistrada WHERE iDFactura = @iDFactura)
    IF EXISTS (SELECT 1 FROM level2.detalleVenta WHERE idFactura = @idFactura)	--Si existe actualizo el precio
    BEGIN
        UPDATE detalleVenta
        SET total = @total,
		cantidadCompras =  @cantidad
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


CREATE OR ALTER PROCEDURE level2.atiendeDetalleVentaDevolucion @idVenta INT, @cantidad INT AS
BEGIN

    DECLARE @total DECIMAL(10, 2);

    -- RESTAR EL MONTO DE DETALLE VENTA LA DEVOLUCION
	DECLARE @idFactura VARCHAR(50) = (SELECT idFactura FROM level2.ventaRegistrada WHERE idVenta = @idVenta )
    SET @total = (SELECT total FROM level2.detalleVenta WHERE iDFactura = @idFactura)
	DECLARE @reembolso DECIMAL(10,2) = (SELECT precioUnitario FROM level2.ventaRegistrada WHERE idVenta = @idVenta) * @cantidad
	SET @total = @total - @reembolso
	--Actualizo
    UPDATE level2.detalleVenta
    SET total = @total,
	cantidadCompras = (cantidadCompras - @cantidad)
    WHERE idFactura = @idFactura;

	UPDATE level2.ventaRegistrada
	SET cantidad = cantidad - @cantidad
	WHERE idVenta = @idVenta
END;

go

----------------------------------------------<Nota Credito>---------------------------------------------------

CREATE OR ALTER PROCEDURE level2.crearNotaCredito @ticketVenta INT, @cantidad INT AS
BEGIN

	if((SELECT idVenta FROM level2.ventaRegistrada WHERE idVenta = @ticketVenta) IS NOT NULL 			--Verifico si la venta existe
	and @cantidad>0 and @cantidad<= (SELECT cantidad FROM level2.ventaRegistrada WHERE idVenta = @ticketVenta) 	--Verifico que la cantidad sea mayor a 0 y menor a los comprado
	)
	BEGIN
	DECLARE @producto VARCHAR(50) = (SELECT producto FROM level2.ventaRegistrada WHERE idVenta = @ticketVenta)
	DECLARE @precioUnitario INT = (SELECT precioUnitario FROM level2.ventaRegistrada WHERE idVenta = @ticketVenta)
	INSERT INTO level2.notaCredito (ticketVenta, nombreProducto, precioUnitario, cantidad)
	VALUES (@ticketVenta, @producto, @precioUnitario, @cantidad)
	EXEC level2.atiendeDetalleVentaDevolucion @ticketVenta, @cantidad
	END
	
	else
		print('Valores no aceptados')


END

CREATE OR ALTER PROCEDURE level2.eliminarNotaCredito @idNC INT AS
BEGIN

DELETE level2.notaCredito WHERE iDNotaCredito = @idNC

END

