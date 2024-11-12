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
					cuil VARCHAR(13) DEFAULT '0',
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
	CREATE TABLE level2.ventaRegistrada(
						iDFactura VARCHAR(50) PRIMARY KEY,
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


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'detalleVenta')
BEGIN
	CREATE TABLE level2.detalleVenta(				
						iDNroDetalle INT PRIMARY KEY IDENTITY(1,1),
						iDFactura VARCHAR(50),
						NombreProducto VARCHAR(100),
						Cantidad INT,
						PrecioUnitario DECIMAL(10,2),
						CONSTRAINT FK_FacturaDetalle FOREIGN KEY(iDFactura)
						REFERENCES level2.ventaRegistrada (iDFactura)
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

CREATE OR ALTER PROCEDURE level2.insertarUnEmpleado 
	@nombre VARCHAR(25), 
	@apellido VARCHAR(50), 
	@dni INT, 
	@direccion VARCHAR(100),
	@emailEmpresa VARCHAR(100), 
	@emailPersonal VARCHAR(100) , 
	@cuil VARCHAR(13), 
	@idCargo VARCHAR(25), 
	@idSucursal VARCHAR(40), 
	@turno VARCHAR(4) 
AS
BEGIN
    -- Valida que el DNI no esté repetido y esté dentro del rango
    IF (SELECT dni FROM level2.empleado WHERE dni = @dni) IS NULL 
        AND (@dni >= 10000000 AND @dni <= 99999999)
    BEGIN
        -- Valida que el cargo y la sucursal existan
        IF (SELECT descripcionCargo FROM level2.cargo WHERE descripcionCargo = @idCargo) IS NOT NULL 
            AND (SELECT nombreSucursal FROM level1.sucursal WHERE nombreSucursal = @idSucursal) IS NOT NULL
        BEGIN
            -- Inserta el nuevo empleado
            INSERT INTO level2.empleado 
                (nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno, estado) 
            VALUES 
                (@nombre, @apellido, @dni, @direccion, @emailEmpresa, @emailPersonal, @cuil, @idCargo, @idSucursal, @turno, '1');
            
            PRINT ('Valores insertados correctamente en la tabla: Empleado.');
        END
        ELSE
            PRINT('El valor de idSucursal y/o idCargo no existe');
    END
    ELSE
        PRINT('No se puede insertar el empleado a la tabla debido a que ya existe un empleado con ese DNI o el DNI tiene un valor incorrecto.');
END
GO
--ES UN EJEMPLO PARA VER SI FUNCIONA
--exec level2.insertarUnEmpleado 'maria', 'moran', 44005719, 'roldan', 'abc@gmial', 'asd@gmail', '30-12221-00', 'Supervisor', 'Palacio Hutt', 'TT'
--select * from level2.empleado




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
	if (@precio > 0) and (@nombreProducto IS NOT NULL and @nombreProducto != '' and (SELECT idProducto FROM level1.producto WHERE nombreProducto = @nombreProducto) IS NULL)
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
		--Verifico que el precio no sea menor a 0
		if (@precio > 0)
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

CREATE OR ALTER PROCEDURE level2.insertarUnaVentaRegistrada @idFactura VARCHAR(50), @tipoFactura CHAR(1),  @ciudad VARCHAR(40), @tipoCliente CHAR(6), @genero VARCHAR(6), 
															@fechaHora DATETIME, @medioPago VARCHAR(25), @legajo_Id INT, @identificadorPago VARCHAR(50)  AS
BEGIN

-- VALIDO SI LA SUCURSAL, EL EMPLEADO, EL MEDIO DE PAGO, GENERO Y EL PRODUCTO ESTAN REGISTRADOS EN LA BASE DE DATOS, Y DE PASO LA CANTIDAD NO SEA NEGATIVA 

		IF (SELECT idSucursal FROM level1.sucursal WHERE ciudad = @ciudad) IS NOT NULL  
        AND (@medioPago ='Credit Card' or @medioPago ='Cash' or @medioPago ='Ewallet')
        AND (@genero = 'Female'or @genero = 'Male') 
        AND (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NOT NULL 
		BEGIN

--INSERTO
			-- Insertar en la tabla entaRegistrada
			INSERT INTO level2.ventaRegistrada (iDFactura, tipoFactura, ciudad, tipoCliente, genero, fechaHora, medioPago, Empleado, identificadorPago)
			VALUES (@idFactura, @tipoFactura, @ciudad, @tipoCliente, @genero, @fechaHora, @medioPago, @legajo_Id, @identificadorPago);
			print('Se ha registrado la factura exitosamente')
		END

		else 
		BEGIN
			print('Revise si los datos son correctos dado que, o no existe la sucursal, producto o empleado, o el medio de pago o la cantidad es invalida')
		END


END
go

CREATE OR ALTER PROCEDURE level2.eliminarVentaRegistrada @idFactura INT AS
BEGIN

DELETE level2.ventaRegistrada WHERE iDFactura = @idFactura


END
go

-------------------------------------------------------<DETALLE VENTA>-------------------------------------------------------------------

CREATE OR ALTER PROCEDURE level2.InsertarDetalleVenta @idFactura VARCHAR(50), @producto VARCHAR(100), @cantidad INT  AS
BEGIN
	-- Verificar si el idFactura existe en la tabla ventaRegistrada
	IF EXISTS(SELECT 1 FROM level2.ventaRegistrada WHERE iDFactura = @idFactura)
	BEGIN
		DECLARE @total DECIMAL(10, 2);

		-- Obtener el precio unitario del producto
		DECLARE @precioUnitario DECIMAL (10,2) = level2.buscarPrecioProducto(@producto)

		-- Insertar en la tabla detalleVenta
		INSERT INTO level2.detalleVenta (iDFactura, NombreProducto, Cantidad, PrecioUnitario)
		VALUES (@idFactura, @producto, @cantidad, @precioUnitario);

		-- Calcular el nuevo total de la factura sumando todos los productos de la factura actual
		SET @total = @cantidad * @precioUnitario;

		SET @total = (@total *  1.21) --SE LE AGREGA EL IVA

        UPDATE level2.ventaRegistrada
        SET MontoTotal = MontoTotal + @total
        WHERE idFactura = @idFactura;
			PRINT 'Monto total actualizado correctamente en ventaRegistrada con el IVA incluido'
	END
	ELSE 
	BEGIN
		PRINT 'Error: La factura con el ID especificado no existe en ventaRegistrada';
	END
END;
go

CREATE OR ALTER PROCEDURE level2.eliminarDetalleVenta @id VARCHAR(25) AS
BEGIN

	DELETE FROM level2.detalleVenta WHERE iDNroDetalle = @id


END
go
--------------------------------------LOTES DE PRUEBA PARA VALIDAR EL FUNCIONAMIENTO DE LAS SP---------------------------------------
EXEC level1.insertarUnSucursal 'Milagro', 'Moron', 'Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires', '5555-5551'
go
EXEC level1.insertarUnSucursal ' ', 'Ramos Mejía', 'Av. de Mayo 791, B1704 Ramos Mejía, Provincia de Buenos Aires', '5555-5552'
go --ESTE MARCA ERROR APROPOSITO
EXEC level1.insertarUnSucursal  'Mandalay', 'Lomas del Mirador', 'Pres. Juan Domingo Perón 763, B1753AWO Villa Luzuriaga, Provincia de Buenos Aires', '5555-5553'
go
select * from level1.sucursal

EXEC level2.insertarCargo 1, 'Supervisor'
GO
EXEC level2.insertarCargo 2, 'Cajero'
GO
EXEC level2.insertarCargo 3, 'Gerente de sucursal'
GO
select * from level2.cargo

EXEC level2.insertarUnEmpleado 'celeste', 'moran', 44005719, 'roldan', 'abc@gmial', 'asd@gmail', '30-12221-00', 'Supervisor', 'Moron', 'TT'
select * from level2.empleado

EXEC level1.insertarUnProducto 'Crema facial', 'cosmetico', 35.8, '330 gr'
go
EXEC level1.insertarUnProducto 'Leche', 'lacteos', 50, '1 litro'
go
EXEC level1.insertarUnProducto 'Pitusas', 'galletitas', 1000, ' gr'
go
select* from level1.producto

EXEC level2.insertarUnaVentaRegistrada '750-67-8428', 'A', 'Milagro', 'Member', 'Female', '01/05/2019 13:08:00', 'Ewallet', 257020, '0000003100099475144530'
go
EXEC level2.insertarUnaVentaRegistrada '226-31-3081', 'C', 'Naypyitaw', 'Normal', 'Female', '03/08/2019 10:29:00',	'Cash',	257020, '--'
go --MARCA ERROR PORQUE EN ESTE CASO LA SUCURSAL NO EXISTE

select * from level2.ventaRegistrada

EXEC level2.InsertarDetalleVenta '750-67-8428', 'Crema facial', 7
GO 
EXEC level2.InsertarDetalleVenta '750-67-8429', 'Leche', 5 --ESTE NO ME DEJA PORQUE PUSE UN ID TRUCHO
GO 
EXEC level2.InsertarDetalleVenta '750-67-8428', 'Pitusas', 1
GO 

select * from level2.detalleVenta
-------------------------------------------------------------------------------------------------------------------------------


	

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

