/* CREACION DE TABLAS Y STORED PROCEDURES BASICOS

-->En este script estara el codigo para crear la base de datos con las tablas iniciales y los sp basicos para hacer funcionar el proyecto
-->Cumplimiento de consigna: Entrega 3, 4 y parte de la 5
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE

*/

use master
drop database Proyecto_Janus
go

CREATE database Proyecto_Janus
GO

use Proyecto_Janus
go

CREATE SCHEMA level1;
GO 
CREATE SCHEMA level2;
GO

---CREACION DE TABLAS----------

CREATE TABLE level1.sucursal(				id_sucursal INT PRIMARY KEY IDENTITY(1,1),
							ciudad VARCHAR(40) not null,
							localidad VARCHAR(40) not null,
							direccion VARCHAR(100) not null)
GO							
CREATE TABLE level2.empleado(id_empleado int primary key,  
							nombre VARCHAR(50),
							apellido VARCHAR(50),
							dni int unique not null,
							direccion VARCHAR(100),
							emailEmpresa VARCHAR(100),
							emailPersonal VARCHAR(100),
							cuil VARCHAR(13),
							cargo VARCHAR(25) not null,
							sucursal VARCHAR(25),
							turno VARCHAR(4) not null)
GO

CREATE TABLE level1.producto(	id_producto int primary key identity(1,1),	 	--1
								categoria VARCHAR (50) not null,			--electronicos
								nombreProd VARCHAR (100) not null,			--macbook
								precio decimal(10,2) not null,				--700
								referenciaUnidad VARCHAR(30) not null)			--(unidad) o cantidad que viene en el paquete)


GO


CREATE TABLE level2.ventaRegistrada(iD_Factura VARCHAR(50) primary key,
									tipo_Factura CHAR(1),
									ciudad VARCHAR(10),
									tipo_Cliente CHAR(6),
									genero VARCHAR(6),
									categoria VARCHAR(50),
									producto VARCHAR(100),
									precioUnitario decimal(10,2),
									cantidad int,
									fechaHora datetime,
									medioPago VARCHAR(12),
									empleado int,
									sucursal VARCHAR(20))
GO


--------SUCURSAL-------------
create procedure level1.insertarUnSucursal @ciudad varchar(25), @localidad varchar(25), @direccion varchar(50) as

    BEGIN
    insert into level1.sucursal (ciudad, localidad, direccion) 
    values (@ciudad, @localidad, @direccion);
	print ('Valores insertados correctamente en la tabla: Sucursal');
    END
go

create procedure level1.borrarSucursal @id_sucursal int AS
BEGIN
	if (select id_sucursal from level1.sucursal where id_sucursal = @id_sucursal) is not null
	BEGIN
		DELETE FROM level1.sucursal WHERE id_sucursal = @id_sucursal
		print ('La sucursal fue eliminada con exito.');
	END
	else
		print('No se ha encontrado la sucursal solicitada.');

END
go



------EMPLEADO------------
create procedure level2.insertarUnEmpleado @id_empleado int, @nombre varchar(25), @apellido varchar(50), @dni int, @direccion varchar(100),
	    			@emailEmpresa varchar(100), @emailPersonal varchar(100) , @cuil varchar(13), @cargo varchar(25), @sucursal varchar(25), 
	    			@turno varchar(4) as

    BEGIN

	if (select id_empleado from level2.empleado where id_empleado = @id_empleado) is null
		BEGIN
		if (select id_empleado from level2.empleado where dni = @dni) is null
			BEGIN
			insert into level2.empleado (id_empleado, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno) 
			values (@id_empleado, @nombre, @apellido, @dni, @direccion, @emailEmpresa, @emailPersonal, @cuil, @cargo, @sucursal, @turno);
			print ('Valores insertados correctamente en la tabla: Empleado.');
			END
		ELSE
		print('No se puede insertar el empleado a la tabla debido a que ya existe un empleado con su dni.');
		END

	ELSE
		print('No se puede insertar el empleado a la tabla debido a que ya existe un empleado con su id.');

    END
go


CREATE PROCEDURE level2.modificarEmpleado 
    @id_empleado int, 
    @nombre varchar(25), 
    @apellido varchar(50), 
    @direccion varchar(100), 
    @emailEmpresa varchar(100), 
    @emailPersonal varchar(100),
	@cuil varchar(13),
    @cargo varchar(25),
	@sucursal varchar(25),
    @turno varchar(25)  
AS
BEGIN
	if (select id_empleado from level2.empleado where id_empleado = @id_empleado) is not null
	BEGIN
		update level2.empleado
		set 
		nombre = @nombre, 
		apellido = @apellido,
		direccion = @direccion, 
		emailEmpresa = @emailEmpresa, 
		emailPersonal = @emailPersonal, 
		cuil = @cuil,
		cargo = @cargo,
		sucursal = @sucursal,
		turno = @turno
		WHERE id_empleado = @id_empleado;
		print('Empleado actualizado.');
	END
	ELSE
		print('No se puede actualizar un empleado que no exista en la tabla.')
END
GO



create procedure level2.borrarEmpleado @id_empleado int AS
BEGIN
	if (select id_empleado from level2.empleado where id_empleado = @id_empleado) is not null
	BEGIN
		DELETE FROM level2.empleado WHERE id_empleado = @id_empleado
		print ('El empleado fue eliminado con exito.');
	END
	else
		print('No se ha encontrado al empleado.');

END
go



---------PRODUCTOS----------

create procedure level1.insertarUnProducto @id_producto int, @categoria varchar(50), @nombreProd varchar(100), @precio decimal(10,2),
	    				@referenciaUnidad varchar(30) as

    BEGIN
	if (select id_producto from level1.producto where id_producto = @id_producto) is null
		BEGIN
		insert into level1.producto (id_producto, Categoria, NombreProd, Precio, ReferenciaUnidad) 
		values (@id_producto, @Categoria, @NombreProd, @Precio, @ReferenciaUnidad);
		print ('Producto insertado exitosamente.')
		END
	ELSE
		print('No se puede insertar el producto dado que su id ya existe en la tabla.')
    END
go


create procedure level1.borrarProducto @id_producto int AS
BEGIN
	if (select id_producto from level1.producto where id_producto = @id_producto) is not null
	BEGIN
		DELETE FROM level1.producto WHERE id_producto = @id_producto
		print ('El producto fue eliminado con exito.');
	END
	else
		print('No se ha encontrado el producto.');

END
go