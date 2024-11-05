----------INTODUCCION ------------------

--En este script estara el codigo para crear la base de datos con las tablas iniciales y el contenido inicial que no dio el cliente



CREATE DATABASE Proyecto_Janus   
USE Proyecto_Janus   
GO


CREATE SCHEMA level1;
GO 
CREATE SCHEMA level2;
GO
	
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
---------CREAR TABLAS--------------

--A continuación se muestra el codigo para crear las tablas de nivel 1

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
							turno VARCHAR(4) not null,
							id_sucur_emp int,
						CONSTRAINT  FK_EmpleadoSucursal foreign key (id_sucur_emp)
						REFERENCES level1.sucursal(id_sucursal))
GO
CREATE TABLE level1.productos(	id_producto int primary key identity(1,1),	 	--1
								Categoria VARCHAR (50) not null,			--electronicos
								NombreProd VARCHAR (100) not null,			--macbook
								Precio decimal(10,2) not null,				--700
								ReferenciaUnidad VARCHAR(30) not null,			--(unidad) o cantidad que viene en el paquete
								id_sucur_prod int,
						CONSTRAINT  FK_ProductoSucursal foreign key (id_sucur_prod)
						REFERENCES level1.sucursal(id_sucursal))
GO
CREATE TABLE level2.VentaRegistrada(ID_Factura VARCHAR(50) primary key,
									Tipo_Factura CHAR(1),
									Ciudad VARCHAR(10),
									Tipo_Cliente CHAR(6),
									Genero VARCHAR(6),
									Categoria VARCHAR(50),
									Producto VARCHAR(100),
									PrecioUnitario decimal(10,2),
									Cantidad int,
									FechaHora datetime,
									MedioPago VARCHAR(12),
									Empleado int,
									Sucursal VARCHAR(20),
									id_sucur_ventas int,
						CONSTRAINT  FK_VentaEmpleado foreign key (Empleado)
						REFERENCES level2.empleado(id_empleado),
						CONSTRAINT  FK_VentaSucursal foreign key (id_sucur_ventas)
						REFERENCES level1.sucursal(id_sucursal),
							CONSTRAINT check_id_factura
							check (ID_Factura LIKE '[0-9]%-[0-9]%-[0-9]%'))
GO
------------------- CREAR STOREDS PROCEDURES -------------------
create procedure level1.insertarUnSucursal @ciudad varchar(25), @localidad varchar(25), @direccion varchar(50) as

    BEGIN
    insert into level1.sucursal (ciudad, localidad, direccion) 
    values (@ciudad, @localidad, @direccion);
    END
go


create procedure level2.insertarUnEmpleado @id_empleado int, @nombre varchar(25), @apellido varchar(50), @dni int, @direccion varchar(100),
	    			@emailEmpresa varchar(100), @emailPersonal varchar(100) , @cuil varchar(13), @cargo varchar(25), @sucursal varchar(25), 
	    			@turno varchar(4) as

    BEGIN
    insert into level2.empleado (id_empleado, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno) 
    values (@id_empleado, @nombre, @apellido, @dni, @direccion, @emailEmpresa, @emailPersonal, @cuil, @cargo, @sucursal, @turno);
    END
go


create procedure level1.insertarUnProducto @id_producto int, Categoria varchar(50), @NombreProd varchar(100), @Precio decimal(10,2),
	    				@ReferenciaUnidad varchar(30), @id_sucur_prod int as

    BEGIN
    insert into level1.productos (id_producto, Categoria, NombreProd, Precio, ReferenciaUnidad, id_sucur_prod) 
    values (@id_producto, @Categoria, @NombreProd, @Precio, @ReferenciaUnidad, @id_sucur_prod);
    END
go
------------------------- INSERCION ----------------------------
-- A continuación se crea las tablas para la creación de los SP que se usaran para la manipulación de tablas
CREATE OR ALTER PROCEDURE level1.insertarSucursal
AS
BEGIN
		CREATE TABLE #tempSuc(
		Ciudad VARCHAR(50),
		Localidad VARCHAR(50),
		Direccion VARCHAR(100));

		INSERT INTO #tempSuc(Ciudad, Localidad, Direccion)
		SELECT 
		Ciudad,
		"Reemplazar por",
		direccion
		FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=directorio.xlsx', 
		'SELECT * FROM [sucursal$]')
		-- Hasta aca hace la importacion de datos a la tabla temporal
		INSERT INTO level1.sucursal(ciudad, localidad, direccion)
		SELECT 
		t.Ciudad,
		t.Localidad,
		t.Direccion
		FROM #tempSuc t
		LEFT JOIN level1.sucursal p ON t.Ciudad = p.ciudad and t.Localidad = p.localidad
		WHERE p.ciudad IS NULL;
		--Hasta aca hace la importacion de unicamente los que no estan incluidos en nuestra tabla de sucursales

		drop table #tempSuc

END;
GO
-----------------------
CREATE OR ALTER PROCEDURE level2.insertarEmpleado
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

		INSERT INTO level2.empleado(id_empleado, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno)
		SELECT 
		t.id_empleado, t.nombre, t.apellido, t.dni, t.direccion, t.emailEmpresa, t.emailPersonal, t.cuil, t.cargo, t.sucursal, t.turno
		FROM #tempEmpleado t
		LEFT JOIN level2.empleado p ON t.id_empleado = p.id_empleado
		WHERE p.id_empleado IS NULL;
		--Hasta aca hace la importacion de unicamente los que no estan incluidos en nuestra tabla de empleados

		drop table #tempEmpleado
END;
GO
------------------------- BORRADO ----------------------------
CREATE OR ALTER PROCEDURE level1.borrarProducto @id_producto int AS
BEGIN
	delete from level1.productos
	WHERE id_producto = @id_producto
END;
GO
----------------------------
CREATE OR ALTER PROCEDURE level2.borrarEmpleado @id_empleado int AS
BEGIN
	delete from level1.empleado
	WHERE id_empleado = @id_empleado
END;
GO
------------------------- MODIFICACIÓN ----------------------------
CREATE OR ALTER PROCEDURE level2.modificarEmpleado 
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
    update level2.empleado
    set 
	nombre = @nombre, 
	direccion = @direccion, 
	emailEmpresa = @emailEmpresa, 
	emailPersonal = @emailPersonal, 
	cargo = @cargo, 
	ciudad = @ciudad, 
	turno = @turno
	WHERE id_empleado = @id_empleado;
END;
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
END;
GO
-----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE level1.ModificarSucursal
    @id_sucursal int,
    @NuevaCiudad varchar(25),
    @NuevaLocalidad varchar(25),
    @NuevaDireccion varchar(50)
AS
BEGIN
    UPDATE level1.sucursal
    SET
        ciudad = @NuevaCiudad,
        localidad = @NuevaLocalidad,
        direccion = @NuevaDireccion
    WHERE id_sucursal = @id_sucursal;
END;
GO
------------------------- IMPORTACIÓN ----------------------------
--- ---------------------------------------------- CATALOGO.CSV
CREATE OR ALTER PROCEDURE level1.ImportarCatalogo 
AS
BEGIN
	DECLARE @Consulta VARCHAR(MAX)
	CREATE TABLE #tempCatalogo (
    id INT,
    category VARCHAR(50),
    name VARCHAR(100),
    price DECIMAL(10,2),
    reference_price DECIMAL(10,2),
    reference_unit VARCHAR(10),
    date VARCHAR(50));
	
	SET @Consulta = N'
        BULK INSERT #tempCatalogo
        FROM ''' + @RutaArchivo + '''
        WITH (
            FORMAT = ''CSV'',
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            FIRSTROW = 2,
            CODEPAGE = ''65001''
        );'
		EXEC sp_executesql @Consulta
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
GO
--- ----------------------------------------------Productos_importados.XLSX
CREATE OR ALTER PROCEDURE level1.ImportarProdImportados
AS
BEGIN
	DECLARE @Consulta VARCHAR(MAX)
	CREATE TABLE #tempImportados(
			IdProducto INT,
			NombreProducto VARCHAR(100),
			Proveedor VARCHAR(100),
			Categoría VARCHAR(100),
			CantidadPorUnidad VARCHAR(100),
			PrecioUnidad DECIMAL(10,2));

	SET @Consulta = N'
        INSERT INTO #tempImportados
        SELECT *
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @RutaArchivo + ',
            ''SELECT * FROM [Listado de Productos$]''
        );'
	    EXEC sp_executesql @Consulta
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
GO
--- ----------------------------------------------Electronic accessories.XLSX
CREATE OR ALTER PROCEDURE level1.ImportarElectronicos
AS
BEGIN
	DECLARE @Consulta VARCHAR(MAX)
	CREATE TABLE #tempElectronicos(
			Producto VARCHAR(100),
			Precio DECIMAL(10,2));

	SET @Consulta = N'
        INSERT INTO #tempElectronicos
        SELECT *
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @RutaArchivo + ',
            ''SELECT * FROM [Sheet1$]''
        );'
   		 EXEC sp_executesql @Consulta
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
GO
--- ----------------------------------------------Ventas_registradas.csv
CREATE OR ALTER PROCEDURE level2.InsertarVentasRegistradas
AS
BEGIN
	CREATE TABLE #tempVenta(
    "ID Factura" VARCHAR(20),
    "Tipo de Factura" VARCHAR(1),
    Ciudad VARCHAR(50),
    "Tipo de cliente" VARCHAR(40),
    Genero VARCHAR(10),
    Producto NVARCHAR(100),
    "Precio Unitario" DECIMAL(10,2),
	Cantidad INT,
	Fecha date,
	hora time,
	"Medio de Pago" VARCHAR(25),
	Empleado INT,
	"Identificador de pago" VARCHAR(50));

	BULK INSERT	#tempVenta
	FROM 'C:\Users\User\Desktop\uni\2- Base de Datos Aplicadas\1-Trabajo Practico\TP_integrador_Archivos\Ventas_registradas.csv'
	WITH( FORMAT= 'CSV',
		FIELDTERMINATOR= ';',
		ROWTERMINATOR= '0x0a',
		FIRSTROW=2,
		CODEPAGE='65001');
	----------------------------------------------
	INSERT INTO level2.VentaRegistrada(ID_Factura, Tipo_Factura, Ciudad, Tipo_Cliente, Genero, Producto, PrecioUnitario,
									Cantidad, FechaHora, MedioPago, Empleado)
	select t.[ID Factura], t.[Tipo de Factura], t.Ciudad, t.[Tipo de cliente], t.Genero, t.Producto, t.[Precio Unitario],
			t.Cantidad, CAST(t.Fecha AS DATETIME) + CAST(t.hora AS DATETIME) AS FechaHoraCompleta, t.[Medio de Pago],
				t.Empleado FROM #tempVenta t

	UPDATE v
	SET v.Categoria = p.Categoria
	FROM level2.VentaRegistrada AS v
	JOIN level1.productos AS p ON v.Producto = p.NombreProd
	WHERE v.Categoria IS NULL;
	
	DROP TABLE #tempVenta
END;
GO
----- INSERCION DE VALORES INICIALES-------------
--Se inicializara los valores que los clientes nos han dado 

EXEC level1.ImportarCatalogo
EXEC level1.ImportarProdImportados
EXEC level1.ImportarElectronicos
SELECT  * FROM level1.productos

EXEC level2.insertarEmpleado
SELECT * FROM level2.empleado

EXEC level1.insertarSucursal
SELECT * FROM level1.sucursal	

EXEC level2.InsertarVentasRegistradas
SELECT * FROM level2.VentaRegistrada

--Ver tablas
SELECT s.name AS SchemaName, o.name AS TableName
FROM sys.objects o
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.type = 'U' AND s.name = 'level1';

SELECT s.name AS SchemaName, o.name AS TableName
FROM sys.objects o
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.type = 'U' AND s.name = 'level2';

--Ver SP
SELECT s.name AS SchemaName, o.name AS ProcedureName
FROM sys.objects o
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.type = 'P' AND s.name = 'level1';

SELECT s.name AS SchemaName, o.name AS ProcedureName
FROM sys.objects o
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.type = 'P' AND s.name = 'level2';


-------ASPECTOS DE SEGURIDAD-----------
--Creo las cuentas y el rol Supervisor

CREATE LOGIN Richtofen
WITH PASSWORD = 'Elemento115!', DEFAULT_DATABASE = Proyecto_Janus,
CHECK_POLICY = ON, CHECK_EXPIRATION = OFF ;

create user Richtofen for login Richtofen

CREATE LOGIN Maxis
WITH PASSWORD = 'Grupo935!', DEFAULT_DATABASE = Proyecto_Janus,
CHECK_POLICY = ON, CHECK_EXPIRATION = OFF ;

create user Maxis for login Maxis



CREATE ROLE Supervisor AUTHORIZATION Richtofen;
GO


--Agrego los miembros al rol Supervisor
ALTER ROLE Supervisor ADD MEMBER Richtofen; 
ALTER ROLE Supervisor ADD MEMBER Maxis; 




REVOKE INSERT, UPDATE, DELETE ON level2.VentaRegistrada TO PUBLIC;
go-- Saco los permisos a todos
GRANT INSERT, UPDATE, DELETE ON level2.VentaRegistrada TO Supervisor;  --Le doy los permisos solo al rol supervisor
go

-----ENCRIPTACION DE EMPLEADOS -----------

USE Proyecto_Janus;
GO

-- Crear la clave simétrica

CREATE SYMMETRIC KEY keyEmpleado 
WITH ALGORITHM = AES_256
ENCRYPTION BY PASSWORD = 'EmpleadoSecretos123!';
GO


select * from level2.empleado
-- Abrir la clave simétrica
OPEN SYMMETRIC KEY KeyEmpleado
    DECRYPTION BY PASSWORD = 'EmpleadoSecretos123!';
GO

-- Encriptar cada columna de la tabla empleado


UPDATE level2.empleado2
SET 
    nombre = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), nombre),
    apellido = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), apellido),
    dni = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'),	CONVERT(varchar, dni)),
    direccion = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), direccion),
    emailEmpresa = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), emailEmpresa),
    emailPersonal = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), emailPersonal),
    cuil = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), cuil),
    cargo = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), cargo),
    sucursal = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), sucursal),
    turno = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), turno),
    id_sucur_emp = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), CONVERT(varchar, id_sucur_emp));
GO

-- Cerrar la clave simétrica
CLOSE SYMMETRIC KEY KeyEmpleado;
GO


select * from level2.empleado


--Nota: Probar


