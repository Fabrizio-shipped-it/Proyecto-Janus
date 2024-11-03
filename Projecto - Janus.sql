----------INTODUCCION ------------------

--En este script estara el codigo para crear la base de datos con las tablas iniciales y el contenido inicial que no dio el cliente



CREATE DATABASE Proyecto_Janus   
USE Proyecto_Janus   
GO


CREATE SCHEMA level1; --este nivel de esquema corresponde a la base de informacion del cual trabajara la base de datos
GO 

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
---------CREAR TABLAS--------------

--A continuación se muestra el codigo para crear las tablas de nivel 1

CREATE TABLE level1.sucursal(				id_sucursal INT PRIMARY KEY IDENTITY(1,1),
							ciudad VARCHAR(40) not null,
							sucursal VARCHAR(40) not null,
							direccion VARCHAR(100) not null)
							
CREATE TABLE level1.empleado(id_empleado int primary key,  
							nombre VARCHAR(50),
							apellido VARCHAR(50),
							dni int unique not null,
							direccion VARCHAR(100),
							emailEmpresa VARCHAR(100),
							emailPersonal VARCHAR(100),
							cuil VARCHAR(13),
							cargo VARCHAR(25) not null,
							sucursal VARCHAR(25),
							turno VARCHAR(4) not null,
							id_sucur_emp int,
						CONSTRAINT  FK_EmpleadoSucursal foreign key (id_sucur_emp)
						REFERENCES level1.sucursal(id_sucursal))

							drop table level1.sucursal
							drop table level1.empleado
							drop table level1.productos
							drop table level1.VentaRegistrada

CREATE TABLE level1.productos(	id_producto int primary key identity(1,1),	 	--1
								Categoria VARCHAR (50) not null,			--electronicos
								NombreProd VARCHAR (100) not null,			--macbook
								Precio decimal(10,2) not null,				--700
								ReferenciaUnidad VARCHAR(30) not null,			--(unidad) o cantidad que viene en el paquete
								id_sucur_prod int,
						CONSTRAINT  FK_ProductoSucursal foreign key (id_sucur_prod)
						REFERENCES level1.sucursal(id_sucursal))
-- -----------------------------------------------------------------------------------------------------------------------
CREATE TABLE level1.VentaRegistrada(ID_Factura VARCHAR(50) primary key,
									Tipo_Factura CHAR(1),
									Ciudad VARCHAR(10),
									Tipo_Cliente CHAR(6),
									Genero VARCHAR(6),
									Linea_Producto VARCHAR(50),
									Producto VARCHAR(50),
									PrecioUnitario decimal(10,2),
									Cantidad int,
									FechaHora datetime,
									MedioPago VARCHAR(12),
									Sucursal VARCHAR(20),
									id_sucur_ventas int,
						CONSTRAINT  FK_VentaSucursal foreign key (id_sucur_ventas)
						REFERENCES level1.sucursal(id_sucursal),
							CONSTRAINT check_id_factura
							check (ID_Factura LIKE '[0-9]%-[0-9]%-[0-9]%')
)

------------------- CREAR STOREDS PROCEDURES -------------------
------------------------- INSERCION ----------------------------
-- A continuación se crea las tablas para la creación de los SP que se usaran para la manipulación de tablas
CREATE OR ALTER PROCEDURE level1.insertarSucursal
AS
BEGIN
		CREATE TABLE #tempSuc(
		Ciudad VARCHAR(50),
		Sucursal VARCHAR(50),
		Direccion VARCHAR(100));

		INSERT INTO #tempSuc(Ciudad, Sucursal, Direccion)
		SELECT 
		Ciudad,
		"Reemplazar por",
		direccion
		FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=directorio.xlsx', 
		'SELECT * FROM [sucursal$]')
		-- Hasta aca hace la importacion de datos a la tabla temporal
		INSERT INTO level1.sucursal(ciudad, sucursal, direccion)
		SELECT 
		t.Ciudad,
		t.Sucursal,
		t.Direccion
		FROM #tempSuc t
		LEFT JOIN level1.sucursal p ON t.Ciudad = p.ciudad and t.Sucursal = p.sucursal
		WHERE p.ciudad IS NULL;
		--Hasta aca hace la importacion de unicamente los que no estan incluidos en nuestra tabla de sucursales

		drop table #tempSuc

END;
-----------------------
CREATE OR ALTER PROCEDURE level1.insertarEmpleado
AS
BEGIN
		CREATE TABLE #tempEmpleado(
		id_empleado INT,
		nombre VARCHAR(50),
		apellido VARCHAR(50),
		dni INT,
		direccion VARCHAR(100),
		emailEmpresa VARCHAR(100),
		emailPersonal VARCHAR(100),
		cuil VARCHAR(15),
		cargo VARCHAR(25),
		sucursal VARCHAR(50),
		turno VARCHAR(5));

		INSERT INTO #tempEmpleado(id_empleado, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno)
		SELECT "Legajo/ID", Nombre, Apellido, DNI, Direccion,
		"email personal", "email empresa", CUIL, Cargo,
		Sucursal, replace(Turno, 'Jornada completa', 'FULL') AS Turno
		FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=directorio.xlsx', 
		'SELECT * FROM [Empleados$]')
		WHERE "Legajo/ID" is not null
		-- Hasta aca hace la importacion de datos a la tabla temporal

		INSERT INTO level1.empleado(id_empleado, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno)
		SELECT 
		t.id_empleado, t.nombre, t.apellido, t.dni, t.direccion, t.emailEmpresa, t.emailPersonal, t.cuil, t.cargo, t.sucursal, t.turno
		FROM #tempEmpleado t
		LEFT JOIN level1.empleado p ON t.id_empleado = p.id_empleado
		WHERE p.id_empleado IS NULL;
		--Hasta aca hace la importacion de unicamente los que no estan incluidos en nuestra tabla de empleados

		drop table #tempEmpleado
END;
------------------------- BORRADO ----------------------------
CREATE OR ALTER PROCEDURE level1.borrarProducto @id_producto int AS
BEGIN
	delete from level1.productos
	WHERE id_producto = @id_producto
END
go


CREATE OR ALTER PROCEDURE level1.borrarEmpleado @id_empleado int AS
BEGIN
	delete from level1.empleado
	WHERE id_empleado = @id_empleado
END
go
------------------------- MODIFICACIÓN ----------------------------
CREATE OR ALTER PROCEDURE level1.modificarEmpleado 
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
GO
-----------------------------------------------------------------
CREATE OR ALTER PROCEDURE level1.modificarProducto 
		@id_producto int,
		@Categoria varchar (50),
		@NombreProd varchar (50),
		@Precio decimal(10,2),	
		@ReferenciaUnidad varchar(30)
AS
BEGIN
    update level1.productos 
    set  
	Categoria = @lineaProducto,
	NombreProd = @NombreProd,
	Precio = @Precio,
	ReferenciaUnidad = @ReferenciaUnidad
	WHERE id_producto = @id_producto;
END
-----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE level1.ModificarSucursal
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
        direccion = @NuevaDireccion
    WHERE id_sucursal = @id_sucursal;
END
go
------------------------- IMPORTACIÓN ----------------------------
--- ---------------------------------------------- CATALOGO.CSV
CREATE OR ALTER PROCEDURE level1.ImportarCatalogo 
AS
BEGIN
	CREATE TABLE #tempCatalogo (
    id INT,
    category VARCHAR(50),
    name VARCHAR(100),
    price DECIMAL(10,2),
    reference_price DECIMAL(10,2),
    reference_unit VARCHAR(10),
    date VARCHAR(50)
);

BULK INSERT	#tempCatalogo FROM 'directorio.csv'
WITH( FORMAT= 'csv',
	FIELDTERMINATOR= ',',
	ROWTERMINATOR= '0x0a',
	FIRSTROW=2,
	CODEPAGE='65001');
	-- hasta aca cargamos en la tabla TEMPORAL
	INSERT INTO level1.productos(Categoria, NombreProd, Precio, ReferenciaUnidad)
	SELECT 
    t.category,
    t.name,
    t.reference_price,
    t.reference_unit
	FROM #tempCatalogo t
	LEFT JOIN level1.productos p ON t.name = p.NombreProd
	WHERE p.NombreProd IS NULL;  -- Solo selecciona los que no existen en la tabla permanente

	SELECT * FROM level1.productos
    DROP TABLE #tempCatalogo
	
END;
--- ----------------------------------------------Productos_importados.XLSX
CREATE OR ALTER PROCEDURE level1.ImportarProdImportados
AS
BEGIN
CREATE TABLE #tempImportados(
			IdProducto INT,
			NombreProducto VARCHAR(100),
			Proveedor VARCHAR(100),
			Categoría VARCHAR(100),
			CantidadPorUnidad VARCHAR(100),
			PrecioUnidad DECIMAL(10,2));

INSERT INTO #tempImportados
SELECT * 
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;Database=directorio.xlsx', 
    'SELECT * FROM [Listado de Productos$]')
	-- Hasta aca hace la importacion de datos a la tabla temporal
	INSERT INTO level1.productos(Categoria, NombreProd, Precio, ReferenciaUnidad)
	SELECT 
    t.Categoría,
	t.NombreProducto,
	t.PrecioUnidad,
	t.CantidadPorUnidad
	FROM #tempImportados t
	LEFT JOIN level1.productos p ON t.NombreProducto = p.NombreProd
	WHERE p.NombreProd IS NULL;
	--Hasta aca hace la importacion de unicamente los que no estan incluidos en nuestra tabla de productos

	SELECT * FROM level1.productos
	DROP TABLE #tempImportados
END;
--- ----------------------------------------------Electronic accessories.XLSX
CREATE OR ALTER PROCEDURE level1.ImportarElectronicos
AS
BEGIN
CREATE TABLE #tempElectronicos(
			Producto VARCHAR(100),
			Precio DECIMAL(10,2));

INSERT INTO #tempElectronicos
SELECT * 
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;Database=directorio.xlsx', 
    'SELECT * FROM [Sheet1$]')
	-- Hasta aca hace la importacion de datos a la tabla temporal
	INSERT INTO level1.productos(Categoria, ReferenciaUnidad, NombreProd, Precio)
	SELECT 
	'Accesorios Electronicos' AS Categoria,
	'ud' AS ReferenciaUnidad,
    t.Producto,
    t.Precio
	FROM #tempElectronicos t
	LEFT JOIN level1.productos p ON t.Producto = p.NombreProd
	WHERE p.NombreProd IS NULL;
	--Hasta aca hace la importacion de unicamente los que no estan incluidos en nuestra tabla de productos

	SELECT * FROM level1.productos
	DROP TABLE #tempElectronicos
END;
----- INSERCION DE VALORES INICIALES-------------
--Se inicializara los valores que los clientes nos han dado 

EXEC level1.ImportarCatalogo
EXEC level1.ImportarProdImportados
EXEC level1.ImportarElectronicos
SELECT  * FROM level1.productos

EXEC level1.insertarEmpleado
SELECT * FROM level1.empleado

EXEC level1.insertarSucursal
SELECT * FROM level1.sucursal


SELECT * FROM level1.VentaRegistrada

--Ver tablas
SELECT s.name AS SchemaName, o.name AS TableName
FROM sys.objects o
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.type = 'U' AND s.name = 'level1';

--Ver SP
SELECT s.name AS SchemaName, o.name AS ProcedureName
FROM sys.objects o
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.type = 'P' AND s.name = 'level1';
