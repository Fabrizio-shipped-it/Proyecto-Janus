----------INTODUCCION ------------------

--En este script estara el codigo para crear la base de datos con las tablas iniciales y el contenido inicial que no dio el cliente


create database Proyecto_Jano      
GO


create schema level1; --este nivel de esquema corresponde a la base de informacion del cual trabajara la base de datos
go 
--create schema level2; --este nivel de esquema corresponde a las tablas relacionadas a los reportes
--go 
---------CREAR TABLAS--------------

--A continuación se muestra el codigo para crear las tablas de nivel 1

create table level1.sucursal(				id_sucursal int primary key identity(1,1),
							ciudad varchar(25) not null,
							sucursal varchar(25) not null,
							direccion varchar(50) not null)

create table level1.empleado(				id_empleado int primary key,
							id_sucur int reference level1.sucursal(id_sucursal),  
							nombre varchar(25),
							apellido varchar(50),
							dni int unique not null,
							direccion varchar(100),
							emailEmpresa varchar(100),
							emailPersonal varchar(100),
							cuil varchar(13),
							cargo varchar(25) not null,
							ciudad varchar(25),
							turno varchar(4) not null)


create table level1.productos(					id_producto int primary key identity(1,1),
								id_sucur int reference level1.sucursal(id_sucursal), --1
								Categoria varchar (50) not null,			--electronicos
								NombreProd varchar (50) not null,			--macbook
								Precio decimal(10,2) not null,				--700
								ReferenciaPrecio decimal(10,2) not null,		--Cuanto pesa o cantidad(1)
								ReferenciaUnidad varchar(30) not null,			--(unidad) o cantidad que viene en el paquete
								FechaCarga datetime not null)
-- -----------------------------------------------------------------------------------------------------------------------
create table level1.VentaRegistrada(					ID Factura varchar(50) primary key,
									Tipo de Factura char(1),
									Ciudad varchar(10),
									Tipo de cliente char(6),
									Genero varchar(6),
									Linea de producto varchar(50),
									Producto varchar(50),
									Precio Unitario decimal(10,2),
									Cantidad int,
									FechaHora datetime,
									Medio de Pago varchar(12),
									Empleado int,
									Sucursal varchar(20),
							CONSTRAINT check_id_factura
							check (ID Factura LIKE '[0-9]%-[0-9]%-[0-9]%')

)
------------------- CREAR STOREDS PROCEDURES -------------------
------------------------- INSERCION ----------------------------
-- A continuación se crea las tablas para la creación de los SP que se usaran para la manipulación de tablas

create procedure level1.insertarSucursal @ciudad varchar(25), @sucursal varchar(25), @direccion varchar(50) as

    BEGIN
    insert into level1.sucursal (ciudad, sucursal, direccion) 
    values (@ciudad, @sucursal, @direccion);
    END
go


create procedure level1.insertarEmpleado @id_empleado int, @nombre varchar(25), @apellido varchar(50), @dni int, @direccion varchar(100),
	    			@emailEmpresa varchar(100), @emailPersonal varchar(100) , @cuil varchar(13), @cargo varchar(25), @ciudad varchar(25), @turno varchar(4) as

    BEGIN
    insert into level1.empleado (id_empleado, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, ciudad, turno) 
    values (@id_empleado, @nombre, @apellido, @dni, @direccion, @emailEmpresa, @emailPersonal, @cuil, @cargo, @ciudad, @turno);
    END
go


create procedure level1.insertarProducto @producto varchar(50), @lineaProducto varchar(50) as

    BEGIN
    insert into level1.productos (producto, lineaProducto) 
    values (@producto, @lineaProducto);
    END
go


create procedure level1.insertarMedioPago @english varchar(25), @spanish varchar(25) as

    BEGIN
    insert into level1.medioPago (english, spanish) 
    values (@english, @spanish);
    END
go
------------------------- BORRADO ----------------------------
create procedure level1.borrarProducto @id_producto int AS
BEGIN
delete from level1.productos
WHERE id_producto = @id_producto
END


create procedure level1.borrarEmpleado @id_empleado int 
AS
BEGIN
	delete from level1.empleado
	WHERE id_empleado = @id_empleado
END
------------------------- MODIFICACIÓN ----------------------------
CREATE PROCEDURE level1.modificarEmpleado 
    @id_empleado int, 
    @nombre varchar(25), 
    @apellido varchar(50), 
    @direccion varchar(100), 
    @emailEmpresa varchar(100), 
    @emailPersonal varchar(100), 
    @cargo varchar(25), 
    @ciudad varchar(25), 
    @turno varchar(25)  
AS
BEGIN
    update level1.empleado
    set 
	nombre = @nombre, 
	direccion = @direccion, 
	emailEmpresa = @emailEmpresa, 
	emailPersonal = @emailPersonal, 
	cargo = @cargo, 
	ciudad = @ciudad, 
	turno = @turno
	WHERE id_empleado = @id_empleado;
END

CREATE PROCEDURE level1.modificarProducto 
    @id_producto int, 
    @producto varchar(50), 
    @lineaProducto varchar(50) 
AS
BEGIN
    update level1.productos 
    set 
	producto = @producto, 
	lineaProducto = @lineaProducto
	WHERE id_producto = @id_producto;
END

CREATE PROCEDURE level1.ModificarSucursal
    @id_sucursal int,
    @NuevaCiudad varchar(25),
    @NuevaSucursal varchar(25),
    @NuevaDireccion varchar(50)
AS
BEGIN
    UPDATE level1.sucursal
    SET
        ciudad = @NuevaCiudad,
        sucursal = @NuevaSucursal,
        direccion = @NuevaDireccion,
    WHERE id_sucursal = @id_sucursal;
END;


----- INSERCION DE VALORES INICIALES-------------
--Se inicializara los valores que los clientes nos han dado 

exec level1.insertarSucursal 'Yangon', 'San Justo', 'Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires';
EXEC level1.insertarSucursal 'Naypyitaw', 'Ramos Mejia', 'Av. de Mayo 791, B1704 Ramos Mejía, Provincia de Buenos Aires';
EXEC level1.insertarSucursal 'Mandalay', 'Lomas del Mirador', ' Pres. Juan Domingo Perón 763, B1753AWO Villa Luzuriaga, Provincia de Buenos Aires';


EXEC level1.insertarEmpleado 257020, 'Romina Alejandra', 'ALIAS', 36383025, 'Bernardo de Irigoyen 2647, San Isidro, Buenos Aires', 'Romina Alejandra_ALIAS@gmail.com', 'Romina Alejandra.ALIAS@superA.com', 36383025, 'Cajero', 'Ramos Mejia', 'TM';
EXEC level1.insertarEmpleado 257021, 'Romina Soledad', 'RODRIGUEZ', 31816587, 'Av. Vergara 1910, Hurlingham, Buenos Aires', 'Romina Soledad_RODRIGUEZ@gmail.com', 'Romina Soledad.RODRIGUEZ@superA.com', 31816587, 'Cajero', 'Ramos Mejia', 'TT';
EXEC level1.insertarEmpleado 257022, 'Sergio Elio', 'RODRIGUEZ', 30103258, 'Av. Belgrano 422, Avellaneda, Buenos Aires', 'Sergio Elio_RODRIGUEZ@gmail.com', 'Sergio Elio.RODRIGUEZ@superA.com', 30103258, 'Cajero', 'Lomas del Mirador', 'TM';
EXEC level1.insertarEmpleado 257023, 'Christian Joel', 'ROJAS', 41408274, 'Calle 7 767, La Plata, Buenos Aires', 'Christian Joel_ROJAS@gmail.com', 'Christian Joel.ROJAS@superA.com', 41408274, 'Cajero', 'Lomas del Mirador', 'TT';
EXEC level1.insertarEmpleado 257024, 'María Roberta de los Angeles', 'ROLON GAMARRA', 30417854, 'Av. Arturo Illia 3770, Malvinas Argentinas, Buenos Aires', 'María Roberta de los Angeles_ROLON GAMARRA@gmail.com', 'María Roberta de los Angeles.ROLON GAMARRA@superA.com', 30417854, 'Cajero', 'San Justo', 'TM';
EXEC level1.insertarEmpleado 257025, 'Rolando', 'LOPEZ', 29943254, 'Av. Rivadavia 6538, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires', 'Rolando_LOPEZ@gmail.com', 'Rolando.LOPEZ@superA.com', 29943254, 'Cajero', 'San Justo', 'TT';
EXEC level1.insertarEmpleado 257026, 'Francisco Emmanuel', 'LUCENA', 37633159, 'Av. Don Bosco 2680, San Justo, Buenos Aires', 'Francisco Emmanuel_LUCENA@gmail.com', 'Francisco Emmanuel.LUCENA@superA.com', 37633159, 'Supervisor', 'Ramos Mejia', 'TM';
EXEC level1.insertarEmpleado 257027, 'Eduardo Matias', 'LUNA', 30338745, 'Av. Santa Fe 1954, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires', 'Eduardo Matias_LUNA@gmail.com', 'Eduardo Matias.LUNA@superA.com', 30338745, 'Supervisor', 'Lomas del Mirador', 'TM';
EXEC level1.insertarEmpleado 257028, 'Mauro Alberto', 'LUNA', 34605254, 'Av. San Martín 420, San Martín, Buenos Aires', 'Mauro Alberto_LUNA@gmail.com', 'Mauro Alberto.LUNA@superA.com', 34605254, 'Supervisor', 'San Justo', 'TM';
EXEC level1.insertarEmpleado 257029, 'Emilce', 'MAIDANA', 36508254, 'Independencia 3067, Carapachay, Buenos Aires', 'Emilce_MAIDANA@gmail.com', 'Emilce.MAIDANA@superA.com', 36508254, 'Supervisor', 'Ramos Mejia', 'TT';
EXEC level1.insertarEmpleado 257030, 'NOELIA GISELA FABIOLA', 'MAIDANA', 34636354, 'Bernardo de Irigoyen 2647, San Isidro, Buenos Aires', 'NOELIA GISELA FABIOLA_MAIDANA@gmail.com', 'NOELIA GISELA FABIOLA.MAIDANA@superA.com', 34636354, 'Supervisor', 'Lomas del Mirador', 'TT';
EXEC level1.insertarEmpleado 257031, 'Fernanda Gisela Evangelina', 'MAIZARES', 33127114, 'Av. Rivadavia 2243, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires', 'Fernanda Gisela Evangelina_MAIZARES@gmail.com', 'Fernanda Gisela Evangelina.MAIZARES@superA.com', 33127114, 'Supervisor', 'San Justo', 'TT';
EXEC level1.insertarEmpleado 257032, 'Oscar Martín', 'ORTIZ', 39231254, 'Juramento 2971, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires', 'Oscar Martín_ORTIZ@gmail.com', 'Oscar Martín.ORTIZ@superA.com', 39231254, 'Gerente de sucursal', 'Ramos Mejia', 'Jornada completa';
EXEC level1.insertarEmpleado 257033, 'Débora', 'PACHTMAN', 30766254, 'Av. Presidente Hipólito Yrigoyen 299, Provincia de Buenos Aires, Provincia de Buenos Aires', 'Débora_PACHTMAN@gmail.com', 'Débora.PACHTMAN@superA.com', 30766254, 'Gerente de sucursal', 'Lomas del Mirador', 'Jornada completa';
EXEC level1.insertarEmpleado 257034, 'Romina Natalia', 'PADILLA', 38974125, 'Lacroze 5910, Chilavert, Buenos Aires', 'Romina Natalia_PADILLA@gmail.com', 'Romina Natalia.PADILLA@superA.com', 38974125, 'Gerente de sucursal', 'San Justo', 'Jornada completa';





exec level1.insertarMedioPago 'Credit card', 'Tarjeta de credito'
exec level1.insertarMedioPago 'Cash', 'Efectivo'
exec level1.insertarMedioPago 'Ewallet', 'Billetera Electronica'









