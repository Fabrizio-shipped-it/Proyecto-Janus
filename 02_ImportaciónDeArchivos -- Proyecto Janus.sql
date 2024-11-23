
use Com2900G07
/*
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO
*/
select * from level1.sucursal
EXEC level1.importarSucursal N'TU DIRECTORIO';
------------------------- INSERCION ----------------------------
-- A continuación se crea las tablas para la creación de los SP que se usaran para la manipulación de tablas
CREATE OR ALTER PROCEDURE level1.importarSucursal 
    @rutaArchivo NVARCHAR(255) -- Parámetro para la ruta del archivo
AS
BEGIN
    -- Crear tabla temporal para almacenar los datos importados
    CREATE TABLE #tempSuc (
        Ciudad VARCHAR(50),
        Localidad VARCHAR(50),
        Direccion VARCHAR(100),
        Telefono VARCHAR(50)
    );
    
    -- Declarar una variable para la consulta dinámica
    DECLARE @sql NVARCHAR(MAX);

    -- Construir la consulta dinámica
    SET @sql = N'
        INSERT INTO #tempSuc (Ciudad, Localidad, Direccion, Telefono)
        SELECT Ciudad, "Reemplazar por", Direccion, Telefono
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @rutaArchivo + ''',
            ''SELECT * FROM [sucursal$]'')';

		    EXEC sp_executesql @sql;

		-- Hasta aca hace la importacion de datos a la tabla temporal
		INSERT INTO level1.sucursal(ciudad, nombreSucursal, direccion, telefono, cuit)
		SELECT 
		t.Ciudad,
		t.Localidad,
		t.Direccion,
		t.Telefono,
		'20-22222222-3' AS cuit
		FROM #tempSuc t
			LEFT JOIN level1.sucursal p 
		    ON t.Ciudad COLLATE Latin1_General_CI_AI = p.ciudad COLLATE Latin1_General_CI_AI
			AND t.Localidad COLLATE Latin1_General_CI_AI = p.nombreSucursal COLLATE Latin1_General_CI_AI
			WHERE p.ciudad IS NULL;
		--Hasta aca hace la importacion de unicamente los que no estan incluidos en nuestra tabla de sucursales

		drop table #tempSuc

END;
GO

EXEC level1.importarSucursal N'C:\Users\User\Desktop\uni\2- Base de Datos Aplicadas\1-Trabajo Practico\TP_integrador_Archivos\Informacion_complementaria.xlsx';
GO 
				--OK
-----------------------
CREATE OR ALTER PROCEDURE level2.importarEmpleado @rutaArchivo NVARCHAR(255)
AS
BEGIN
		CREATE TABLE #tempEmpleado(
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
		   
		
				DECLARE @sql NVARCHAR(MAX);

		SET @sql = N'
        INSERT INTO #tempEmpleado(nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno)
		SELECT Nombre, Apellido, DNI, Direccion,
		"email personal", "email empresa", CUIL, Cargo,
		Sucursal, replace(Turno, ''Jornada completa'', ''FULL'') AS Turno
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @rutaArchivo + ''',
            ''SELECT * FROM [Empleados$]
			WHERE DNI IS NOT NULL'')';

		    EXEC sp_executesql @sql;
		-- Hasta aca hace la importacion de datos a la tabla temporal
		INSERT INTO level2.empleado(nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno, estado)
		SELECT 
		t.nombre, t.apellido, t.dni, t.direccion, t.emailEmpresa, t.emailPersonal, t.cuil, t.cargo, t.sucursal, t.turno, '1' AS estado
		FROM #tempEmpleado t
		LEFT JOIN level2.empleado e ON t.nombre = e.nombre AND t.apellido = e.apellido
		WHERE e.dni IS NULL
		--Hasta aca hace la importacion de unicamente los que no estan incluidos en nuestra tabla de empleados
		drop table #tempEmpleado
END;
GO

EXEC level2.importarEmpleado N'C:\Users\User\Desktop\uni\2- Base de Datos Aplicadas\1-Trabajo Practico\TP_integrador_Archivos\Informacion_complementaria.xlsx';
GO
--select * from level2.empleado
--delete from level2.empleado
									--OK
------------------------- IMPORTACIÓN ----------------------------
--- ---------------------------------------------- CATALOGO.CSV	
CREATE OR ALTER PROCEDURE level1.ImportarCatalogo @RutaArchivo NVARCHAR(270)
AS
BEGIN
		DECLARE @Consulta NVARCHAR(MAX)
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
            CODEPAGE = ''65001'');'

		EXEC sp_executesql @Consulta
	-- hasta aca cargamos en la tabla TEMPORAL
	INSERT INTO level1.producto(Categoria, nombreProducto, precio, ReferenciaUnidad, estado)
	SELECT 
    t.category,
    t.name,
    t.reference_price,
    t.reference_unit,
	'1' AS estado
	FROM #tempCatalogo t
	LEFT JOIN level1.producto p ON t.name = p.nombreProducto
	WHERE p.nombreProducto IS NULL;  -- Solo selecciona los que no existen en la tabla permanente
    DROP TABLE #tempCatalogo
END
GO

EXEC level1.ImportarCatalogo N'C:\Users\User\Desktop\uni\2- Base de Datos Aplicadas\1-Trabajo Practico\TP_integrador_Archivos\Productos\catalogo.csv';
GO
--select * from level1.producto
--delete from level1.producto
								--OK
--- ----------------------------------------------Productos_importados.xlsx
CREATE OR ALTER PROCEDURE level1.ImportarProdImportados @RutaArchivo NVARCHAR(270)
AS
BEGIN
		DECLARE @Consulta NVARCHAR(MAX)
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
            ''Excel 12.0;Database=' + @RutaArchivo + ''',''SELECT * FROM [Listado de Productos$]'');';
    EXEC sp_executesql @Consulta
	-- Hasta aca hace la importacion de datos a la tabla temporal
	INSERT INTO level1.producto(Categoria, nombreProducto, Precio, ReferenciaUnidad, estado)
	SELECT 
    t.Categoría,
	t.NombreProducto,
	t.PrecioUnidad,
	t.CantidadPorUnidad,
	'1' AS estado
	FROM #tempImportados t
	LEFT JOIN level1.producto p ON t.NombreProducto = p.nombreProducto
	WHERE p.nombreProducto IS NULL;
	--Hasta aca hace la importacion de unicamente los que no estan incluidos en nuestra tabla de productos

	DROP TABLE #tempImportados
END;
GO

EXEC level1.ImportarProdImportados N'C:\Users\User\Desktop\uni\2- Base de Datos Aplicadas\1-Trabajo Practico\TP_integrador_Archivos\Productos\Productos_importados.xlsx';
GO
--select * from level1.producto
--delete from level1.producto
								--OK
--- ----------------------------------------------Electronic accessories.xlsx
CREATE OR ALTER PROCEDURE level1.ImportarElectronicos @RutaArchivo NVARCHAR(270)	
AS
BEGIN
    -- Declaración de la consulta dinámica
    DECLARE @Consulta NVARCHAR(MAX);

    -- Crear la tabla temporal para almacenar los datos importados
    CREATE TABLE #tempElectronicos(
        Producto VARCHAR(100),
        Precio DECIMAL(10,2)
    );

    -- Construcción de la consulta dinámica para realizar el INSERT a la tabla temporal
		SET @Consulta = N'
     INSERT INTO #tempElectronicos
        SELECT *
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;Database=' + @RutaArchivo + ''',''SELECT * FROM [Sheet1$]'');';

    -- Ejecución de la consulta dinámica
    EXEC sp_executesql @Consulta;

    -- Inserción en la tabla final (productos), únicamente para productos nuevos
    INSERT INTO level1.producto(Categoria, ReferenciaUnidad, nombreProducto, Precio, estado)
    SELECT
        'Accesorios Electronicos' AS Categoria,
        'ud' AS ReferenciaUnidad,
        t.Producto,
        t.Precio,
		'1' AS estado
    FROM #tempElectronicos t
    LEFT JOIN level1.producto p ON t.Producto = p.nombreProducto
    WHERE p.nombreProducto IS NULL;

    -- Limpieza de la tabla temporal
    DROP TABLE #tempElectronicos;
END;
GO

EXEC level1.ImportarElectronicos N'C:\Users\User\Desktop\uni\2- Base de Datos Aplicadas\1-Trabajo Practico\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';
GO
--select * from level1.producto
--delete from level1.producto
								--OK



	----------------------------------- FALTA QUE FABRI TERMINE DE HACER EL DE VENTAS PERO PARA ESO LAS TABLAS TIENE QUE ESTAR VERIFICADAS POR LOS 3 UWU
--- ----------------------------------------------Ventas_registradas.csv
CREATE OR ALTER PROCEDURE level2.InsertarVentasRegistradas @RutaArchivo NVARCHAR(270)
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

	DECLARE @Consulta NVARCHAR(MAX);
    SET @Consulta = N'
        BULK INSERT #tempVenta
        FROM ''' + @RutaArchivo + '''
        WITH (
            FORMAT = ''CSV'',
            FIELDTERMINATOR = '';'',
            ROWTERMINATOR = ''0x0a'',
            FIRSTROW = 2,
            CODEPAGE = ''65001''
        );';

    -- Ejecutar la consulta dinámica
    EXEC sp_executesql @Consulta;
	----------------------------------------------

		INSERT INTO level2.ventaRegistrada(iDFactura, tipoFactura, Ciudad, tipoCliente, Genero, fechaHora, medioPago,
																								Empleado, MontoTotal, identificadorPago)
				SELECT t.[ID Factura], t.[Tipo de Factura], t.Ciudad, t.[Tipo de cliente], t.Genero,
					CAST(t.Fecha AS DATETIME) + CAST(t.hora AS DATETIME) AS FechaHoraCompleta, t.[Medio de Pago], t.Empleado,
					 t.Cantidad * t.[Precio Unitario] AS MontoTotal, t.[Identificador de pago]
						FROM #tempVenta t
				LEFT JOIN level2.ventaRegistrada vr ON t.[ID Factura] = vr.iDFactura
				WHERE vr.iDFactura IS NULL; 
	
			INSERT INTO level2.detalleVenta(iDFactura, NombreProducto, Cantidad, PrecioUnitario)
					SELECT x.[ID Factura], x.Producto, x.Cantidad, x.[Precio Unitario]
					FROM #tempVenta x
			LEFT JOIN level2.detalleVenta dv ON x.[ID Factura] = dv.iDFactura
			WHERE dv.iDFactura IS NULL;
	
	DROP TABLE #tempVenta
END;
GO
EXEC level2.InsertarVentasRegistradas N'TU DIRECTORIO';


/*
select * from level2.ventaRegistrada
truncate table level2.ventaRegistrada

select * from level2.detalleVenta
truncate table level2.detalleVenta

select * from level1.producto
truncate table level1.producto

select * from level2.empleado
truncate table level2.empleado

select * from level1.sucursal
truncate table level1.sucursal
*/
