-------------------------------<CREACION DE TABLAS Y STORED PROCEDURES BASICOS>-----------------------------------------

/* 
==========================================<Introduccion>===================================================================

-->En este script esta el codigo de importacion


-->Cumplimiento de consigna: Entrega 4
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7: Proyecto Janus


	DNI			DIRECTORES DEL PROYECTO
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE


=================================================<Indice>===================================================================

+ SP INSERSION
+ SELECTS

===================================================

*/



use Com2900G07

/*
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO
*/

EXEC level2.insertarCargo 1, 'Supervisor'
GO
EXEC level2.insertarCargo 2, 'Cajero'
GO
EXEC level2.insertarCargo 3, 'Gerente de sucursal'
GO
EXEC level1.insertarMedioPago N'Cash';
GO
EXEC level1.insertarMedioPago N'Credit card';
GO
EXEC level1.insertarMedioPago N'Ewallet';
GO


------------------------------------<SP INSERCION>------------------------------------------------------------------------------
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

EXEC level1.importarSucursal N'C:\DDBBA\TP_integrador_Archivos\Informacion_complementaria.xlsx';
GO 
--select * from level1.sucursal
--delete from level1.sucursal
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
		t.nombre, t.apellido, t.dni, t.direccion, t.emailEmpresa, t.emailPersonal, '00-00000000-0' AS cuil, t.cargo, t.sucursal, t.turno, '1' AS estado
		FROM #tempEmpleado t
		LEFT JOIN level2.empleado e ON t.nombre = e.nombre AND t.apellido = e.apellido
		WHERE e.dni IS NULL
		--Hasta aca hace la importacion de unicamente los que no estan incluidos en nuestra tabla de empleados
		drop table #tempEmpleado
END;
GO

EXEC level2.importarEmpleado N'C:\DDBBA\TP_integrador_Archivos\Informacion_complementaria.xlsx';
GO

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

EXEC level1.ImportarCatalogo N'C:\DDBBA\TP_integrador_Archivos\Productos\catalogo.csv';
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

EXEC level1.ImportarProdImportados N'C:\DDBBA\TP_integrador_Archivos\Productos\Productos_importados.xlsx';
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

EXEC level1.ImportarElectronicos N'C:\DDBBA\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';
GO
--select * from level1.producto
--delete from level1.producto
								--OK
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
		
	----------------------------------------------
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

		UPDATE #tempVenta
SET Producto = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Producto,'Ã¡', 'á'),'Ã©', 'é'),'Ã­', 'í'),'Ã³', 'ó'),'Ãº', 'ú'),'Ã±', 'ñ'),'Â', ''),'å˜', 'ojo'),'í', 'Á'),'líƒÂº', 'lú'),'chí­a', 'chía'),'lí­quido', 'líquido'),'encí­as', 'encías'),'raí­ces', 'raíces'),'proteí­nas', 'proteínas');


		INSERT INTO level2.ventaRegistrada(total_Bruto, total_IVA, empleado, iD_MedioPago, identificadorPago)
				SELECT (t.Cantidad * t.[Precio Unitario]) AS total_Bruto, CAST(((t.Cantidad * t.[Precio Unitario]) * 1.21) AS DECIMAL(10,2)) AS total_IVA,
							t.Empleado, mp.idMedioPago, t.[Identificador de pago]
						FROM #tempVenta t
				JOIN level1.medioPago mp ON t.[Medio de Pago]= mp.descripcion
				LEFT JOIN level2.ventaRegistrada vr ON t.[Identificador de pago] = vr.identificadorPago
				WHERE vr.identificadorPago IS NULL
	--Insertó en venta --OK


		INSERT INTO level2.factura(iD_Factura,iD_Sucursal, tipoFactura, fechaHora, estado, cuit)
				SELECT t.[ID Factura],sc.idSucursal, t.[Tipo de Factura], CAST(t.Fecha AS DATETIME) + CAST(t.hora AS DATETIME) AS FechaHoraCompleta,
							'PAGADA' AS estado, sc.cuit
				FROM #tempVenta t
				JOIN level1.sucursal sc ON t.Ciudad = sc.ciudad
				LEFT JOIN level2.factura fc ON t.[ID Factura] = fc.iD_Factura
				WHERE fc.iD_Factura IS NULL

		UPDATE fc
		SET fc.iD_Venta = vr.iD_Venta
		FROM level2.factura fc
		JOIN #tempVenta tmp ON fc.iD_Factura = tmp.[ID Factura]
		JOIN level2.ventaRegistrada vr ON tmp.[Identificador de pago] = vr.identificadorPago
		WHERE fc.iD_Venta IS NULL
	--Insertó en factura --OK


		INSERT INTO level2.detalleVenta(nombreProducto, cantidad, precioUnitario)
			SELECT t.Producto, t.Cantidad, t.[Precio Unitario] FROM #tempVenta t
			LEFT JOIN level2.detalleVenta dt ON dt.nombreProducto = t.Producto
			WHERE dt.nombreProducto IS NULL

		
	--Insertó en detalle

	DROP TABLE #tempVenta
END;
GO

EXEC level2.InsertarVentasRegistradas N'C:\DDBBA\TP_integrador_Archivos\Ventas_registradas.csv';
go

select * from level2.empleado
SELECT * FROM level1.sucursal
select * from level1.producto
SELECT * FROM level2.ventaRegistrada


/*
select * from level2.ventaRegistrada
delete from level2.ventaRegistrada

select * from level2.factura
delete from level2.factura

select * from level2.detalleVenta
truncate table level2.detalleVenta
*/

