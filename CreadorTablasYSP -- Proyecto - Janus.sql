/* CREACION DE TABLAS Y STORED PROCEDURES BASICOS

-->En este script estara el codigo para crear la base de datos con las tablas iniciales y los sp basicos para hacer funcionar el proyecto
-->Cumplimiento de consigna: Entrega 3
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE

*/

use master
drop database Com2900G07
go

CREATE database Com2900G07
GO

use Com2900G07
go

CREATE SCHEMA level1;
GO 
CREATE SCHEMA level2;
GO

---CREACION DE TABLAS----------

CREATE TABLE level1.sucursal(	idSucursal INT PRIMARY KEY IDENTITY(1,1),
								ciudad VARCHAR(40) NOT NULL,
								nombreSucursal VARCHAR (40) NOT NULL,
								direccion VARCHAR(100) NOT NULL,
								telefono VARCHAR(10) NOT NULL)
GO					


CREATE TABLE level1.catalogo(	idCatalogo INT PRIMARY KEY IDENTITY(1,1), --  <-- ¿Identity?
								nombre VARCHAR(50) NOT NULL)
GO

CREATE TABLE level1.producto(	idProducto INT PRIMARY KEY IDENTITY(1,1),	 	
								idCatalogo INT NOT NULL REFERENCES level1.catalogo(idCatalogo),			
								nombreProducto VARCHAR (100) NOT NULL,			
								precio DECIMAL(10,2) NOT NULL)			
GO

CREATE TABLE level2.cargo(	idCargo INT PRIMARY KEY,
							descripcionCargo VARCHAR (25) NOT NULL UNIQUE)
GO


CREATE TABLE level2.empleado(	legajo_Id INT PRIMARY KEY CHECK (legajo_Id > 257000),  
								nombre VARCHAR(50) NOT NULL,
								apellido VARCHAR(50) NOT NULL,
								dni INT UNIQUE NOT NULL CHECK (dni >= 10000000 and dni <= 99999999),
								direccion VARCHAR(100),
								emailEmpresa VARCHAR(100),
								emailPersonal VARCHAR(100),
								cuil VARCHAR(13),
								idCargo INT REFERENCES level2.cargo(idCargo),				--	<-- FK a la tabla cargo
								idSucursal INT REFERENCES level1.sucursal (idSucursal),		--  <-- FK a la tabla sucursal
								turno VARCHAR(4) NOT NULL)
GO




CREATE TABLE level2.ventaRegistrada(iDFactura VARCHAR(50) PRIMARY KEY,
									tipoFactura CHAR(1),
									ciudad VARCHAR(10),
									tipoCliente CHAR(6),
									genero VARCHAR(6),
									producto VARCHAR(100),
									precioUnitario DECIMAL(10,2),
									cantidad INT,
									fecha DATE,
									hora TIME,
									idMedioPago INT REFERENCES level2.medioPago(idMedioPago),
									identificadorPago VARCHAR(50) UNIQUE,
									legajo_Id INT REFERENCES level2.empleado(legajo_Id),
									sucursal VARCHAR(20),
									importeTotal DECIMAL(10,2)
									)
GO

CREATE TABLE level2.medioPago(	idMedioPago INT PRIMARY KEY, 
								descripcionPagoEspanol VARCHAR(25) UNIQUE,
								descripcionPagoIngles VARCHAR(25) UNIQUE)
GO



----------------------------------SUCURSAL---------------------------------------------------------------------

CREATE PROCEDURE level1.insertarUnSucursal @ciudad VARCHAR(25), @nombreSucursal VARCHAR(40), @direccion VARCHAR(100), @telefono VARCHAR(10) AS
BEGIN
    if (@ciudad IS NOT NULL and @ciudad != '' and @nombreSucursal IS NOT NULL and @nombreSucursal != '' and @direccion IS NOT NULL and @direccion != '' and @telefono IS NOT NULL and @telefono != '' )

    BEGIN
        INSERT INTO level1.sucursal (ciudad, nombreSucursal, direccion, telefono) 
        VALUES (@ciudad, @nombreSucursal, @direccion, @telefono)
        PRINT ('Valores insertados correctamente en la tabla: Sucursal')
    END

    else
    BEGIN

        PRINT ('No se puede insertar a la tabla debido a que falta uno o más valores, o los valores superan el límite permitido.')

    END
END
GO




CREATE PROCEDURE level1.modificarSucursal @idSucursal INT, @ciudad VARCHAR(25), @nombreSucursal VARCHAR(40), @direccion VARCHAR(100), @telefono VARCHAR(10) AS

	BEGIN
	if (SELECT idSucursal FROM level1.sucursal WHERE idSucursal = @idSucursal) IS NOT NULL
		BEGIN

		if (@ciudad IS NOT NULL and @ciudad != '' and @nombreSucursal IS NOT NULL and @nombreSucursal != '' and @direccion IS NOT NULL and @direccion != '' and @telefono IS NOT NULL and @telefono != '' )
			BEGIN

			UPDATE level1.sucursal
			SET
			ciudad = @ciudad,
			nombreSucursal = @nombreSucursal,
			direccion = @direccion,
			telefono = @telefono

			END
		else
			PRINT ('No se puede actualizar valores vacios.')

		END
	else
		PRINT ('No se ha encontrado la sucursal que se quiere modificar')

	END
GO


CREATE PROCEDURE level1.borrarSucursal @id_sucursal INT AS
BEGIN
	if (SELECT idSucursal FROM level1.sucursal WHERE idSucursal = @id_sucursal) IS NOT NULL
	BEGIN

		DELETE FROM level1.sucursal WHERE idSucursal = @id_sucursal
		PRINT ('La sucursal fue eliminada con exito.')

	END
	else
		print('No se ha encontrado la sucursal solicitada.')

END
GO

------------------------------------------------CARGO---------------------------------------------------------------------

CREATE PROCEDURE level2.insertarCargo  @idCargo INT, @descripcionCargo VARCHAR(25) AS
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
EXEC level2.insertarCargo 3, 'Gerente Sucursal'
GO



CREATE PROCEDURE level2.borrarCargo @idCargo INT AS
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


------------------------------------------------EMPLEADO------------------------------------------------------------------

CREATE PROCEDURE level2.insertarUnEmpleado @legajo_Id INT, @nombre VARCHAR(25), @apellido VARCHAR(50), @dni INT, @direccion VARCHAR(100),
	    			@emailEmpresa VARCHAR(100), @emailPersonal VARCHAR(100) , @cuil VARCHAR(13), @idCargo INT, @idSucursal INT, @turno VARCHAR(4) AS

    BEGIN

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NULL and (@legajo_Id >257000)
		BEGIN

		if (SELECT legajo_Id FROM level2.empleado WHERE dni = @dni) IS NULL and (@dni >=10000000 and @dni <= 99999999)
			BEGIN

			if(SELECT idCargo FROM level2.cargo WHERE idCargo = @idCargo) IS NOT NULL AND (SELECT idSucursal FROM level1.sucursal WHERE idSucursal = @idSucursal) IS NOT NULL
				BEGIN

				INSERT INTO  level2.empleado (legajo_Id, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, idCargo, idSucursal, turno) 
				VALUES (@legajo_Id, @nombre, @apellido, @dni, @direccion, @emailEmpresa, @emailPersonal, @cuil, @idCargo, @idSucursal, @turno);
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




CREATE PROCEDURE level2.modificarEmpleado @legajo_Id INT, @nombre VARCHAR(25), @apellido VARCHAR(50), @direccion VARCHAR(100),
	    			@emailEmpresa VARCHAR(100), @emailPersonal VARCHAR(100) , @cuil VARCHAR(13), @idCargo INT, @idSucursal INT, @turno VARCHAR(4) AS
BEGIN

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NOT NULL
	BEGIN

		if(SELECT idCargo FROM level2.cargo WHERE idCargo = @idCargo) IS NOT NULL AND (SELECT idSucursal FROM level1.sucursal WHERE idSucursal = @idSucursal) IS NOT NULL
		BEGIN
		UPDATE level2.empleado
		SET
		nombre = @nombre, 
		apellido = @apellido,
		direccion = @direccion, 
		emailEmpresa = @emailEmpresa, 
		emailPersonal = @emailPersonal, 
		cuil = @cuil,
		idCargo = @idCargo,
		idSucursal = @idSucursal,
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



CREATE PROCEDURE level2.borrarEmpleado @legajo_Id INT AS
BEGIN

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NOT NULL
	BEGIN

		DELETE FROM level2.empleado WHERE legajo_Id = @legajo_Id
		print ('El empleado fue eliminado con exito.')
	END

	else
		print('No se ha encontrado al empleado.')

END
GO


------------------------------------------------------CATALOGO------------------------------------------------

CREATE PROCEDURE level1.insertarCatalogo @nombre VARCHAR(25) AS
BEGIN

	if(SELECT nombre FROM level1.catalogo WHERE nombre = @nombre) IS NULL
		BEGIN
		INSERT INTO level1.catalogo (nombre) 
		VALUES (@nombre)
		print('Se ha agregado al catalogo correctamente.')
		END

	else
		print('Ya existe ese catalogo en la lista')
END
GO


CREATE PROCEDURE level1.modificarCatalogo @idCatalogo INT, @nombre VARCHAR(25) AS
BEGIN
	if(SELECT idCatalogo FROM level1.catalogo WHERE nombre = @nombre) IS NULL and (SELECT idCatalogo FROM level1.catalogo WHERE idCatalogo = @idCatalogo) IS NOT NULL
	BEGIN
	UPDATE level1.catalogo
	SET
	nombre = @nombre
	WHERE idCatalogo = @idCatalogo
	print('Catalogo actualizado')
	END
	else
	print('No se puede actualizar el catalogo ya sea porque no existe, o porque ya existe un catalogo con ese nombre')


END
GO

CREATE PROCEDURE level1.borrarCatalogo @idCatalogo INT AS
BEGIN 

	if(SELECT idCatalogo FROM level1.catalogo WHERE idCatalogo = @idCatalogo) IS NOT NULL
	BEGIN
	DELETE level1.catalogo WHERE idCatalogo = @idCatalogo
	print ('Catalogo eliminado')
	END
	else 
	print('No existe el catalogo que quiere eliminar.')
END
GO

----------------------------------------------------PRODUCTOS------------------------------------------------------------


CREATE PROCEDURE level1.insertarUnProducto  @idCatalogo INT, @nombreProducto VARCHAR(100), @precio DECIMAL(10,2) AS

    BEGIN

	if (@precio >= 0) and (@nombreProducto IS NOT NULL and @nombreProducto != '' and (SELECT idProducto FROM level1.producto WHERE nombreProducto = @nombreProducto) IS NULL) and (SELECT idCatalogo FROM level1.catalogo WHERE idCatalogo = @idCatalogo) IS NOT NULL
 		BEGIN

		INSERT INTO level1.producto (idCatalogo, nombreProducto, precio)
		VALUES (@idCatalogo, @nombreProducto, @precio)
		print ('Producto insertado exitosamente')
		END

	else
		print('No se puede insertar el producto dado que los datos a insertar son erroneos.')
    END
GO

CREATE PROCEDURE level1.modificarProducto @idProducto INT, @idCatalogo INT, @nombreProducto VARCHAR(100), @precio DECIMAL(10,2) AS

BEGIN
if (SELECT idProducto FROM level1.producto WHERE idProducto = @idProducto) IS NOT NULL
	BEGIN
	if (@precio >= 0) and (@nombreProducto IS NOT NULL and @nombreProducto != '') and (SELECT idProducto FROM level1.producto WHERE nombreProducto = @nombreProducto) IS NULL and (SELECT idCatalogo FROM level1.catalogo WHERE idCatalogo = @idCatalogo) IS NOT NULL
		BEGIN
		UPDATE level1.producto
		SET
		@precio = precio,
		@nombreProducto = nombreProducto,
		@idCatalogo = idCatalogo
		print('Se ha actualizado el producto exitosamente')
		END
	else
	print('Los datos a actualizar son erroneos')
	END
else
	print('El producto a actualizar no se encuentra en la tabla')

END
GO



CREATE PROCEDURE level1.borrarProducto @idProducto INT AS
BEGIN
	if (SELECT idProducto FROM level1.producto WHERE idProducto = @idProducto) IS NOT NULL
	BEGIN

		DELETE FROM level1.producto WHERE idProducto = @idProducto
		print ('El producto fue eliminado con exito.');
	END
	else
		print('No se ha encontrado el producto.');

END
go
