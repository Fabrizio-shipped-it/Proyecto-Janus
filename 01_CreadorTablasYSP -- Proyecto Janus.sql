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
+SP Sucrusal
+SP Cargo
+SP Empleado
+SP Catalogo
+SP Productos
+SP MedioPago



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
CREATE TABLE level2.empleado(	legajo_Id INT PRIMARY KEY CHECK (legajo_Id > 257000),  
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
								estado varchar(10) CHECK (estado = 'Activo' or estado = 'Inactivo'))
END
GO




IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'producto')
BEGIN
	CREATE TABLE level1.producto(	idProducto INT PRIMARY KEY IDENTITY(1,1),	 	
									Categoria VARCHAR(50) NOT NULL,			
									nombreProducto VARCHAR (100) NOT NULL,			
									precio DECIMAL(10,2) NOT NULL)			
END
GO







IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'medioPago')
BEGIN
CREATE TABLE level2.medioPago(	idMedioPago INT PRIMARY KEY CHECK (idMedioPago > 0), 
								descripcionPagoEspanol VARCHAR(25) UNIQUE,
								descripcionPagoIngles VARCHAR(25) UNIQUE)
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

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NULL and (@legajo_Id >257000)	--VALIDO EL LEGAJO SEA DE 257
		BEGIN

		if (SELECT legajo_Id FROM level2.empleado WHERE dni = @dni) IS NULL and (@dni >=10000000 and @dni <= 99999999)  --DVALIDO DNI ACEPTABLE Y NO REPETIBLE
			BEGIN

				--VALIDO QUE EXISTA EL CARGO Y LA SUCURSAL
			if(SELECT idCargo FROM level2.cargo WHERE descripcionCargo = @idCargo) IS NOT NULL AND (SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal = @idSucursal) IS NOT NULL
				BEGIN

				INSERT INTO  level2.empleado (legajo_Id, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno, estado) 
				VALUES (@legajo_Id, @nombre, @apellido, @dni, @direccion, @emailEmpresa, @emailPersonal, @cuil, @idCargo, @idSucursal, @turno, 'Activo');
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
		estado = 'Inactivo'
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
		estado = 'Activo'
		WHERE legajo_Id = @legajo_Id
		print ('El empleado fue reactivado.')
	END

	else
		print('No se ha encontrado al empleado.')

END
GO
----------------------------------------------------<PRODUCTOS>------------------------------------------------------------


CREATE OR ALTER PROCEDURE level1.insertarUnProducto   @nombreProducto VARCHAR(100), @Categoria VARCHAR(50), @precio DECIMAL(10,2) AS

    BEGIN
	--Verifico precio, que el producto no exista
	if (@precio >= 0) and (@nombreProducto IS NOT NULL and @nombreProducto != '' and (SELECT idProducto FROM level1.producto WHERE nombreProducto = @nombreProducto) IS NULL)
 		BEGIN

		INSERT INTO level1.producto (nombreProducto, Categoria, precio)
		VALUES (@nombreProducto, @Categoria, @precio)
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


-------------------------------------<MEDIO PAGO> --------------------------------------------------------------

CREATE OR ALTER PROCEDURE level2.insertarMedioPago @idMedioPago INT, @descripcionPagoEspanol VARCHAR(25), @descripcionPagoIngles VARCHAR(25) AS
BEGIN
	if(@idMedioPago>0 and (SELECT idMedioPago FROM level2.medioPago WHERE idMedioPago = @idMedioPago) IS NULL and (SELECT idMedioPago FROM level2.medioPago WHERE descripcionPagoEspanol = @descripcionPagoEspanol) IS NULL and (SELECT idMedioPago FROM level2.medioPago WHERE descripcionPagoIngles = @descripcionPagoIngles) IS NULL ) 
		BEGIN

		INSERT INTO level2.medioPago (idMedioPago, descripcionPagoEspanol, descripcionPagoIngles) 
		VALUES(@idMedioPago, @descripcionPagoEspanol, @descripcionPagoIngles)
		print('Nuevo medio pago aceptado')
		END
	else
		print('Id invalido, o algun valor se repite')
END
GO



