

--ANTES DE EMPEZAR POR PRIMERA VEZ, es necesario que ejecute estas sentencias y reinicie el sql. Solo HAGALO LA PRIMERA VEZ, esto le dara permisos a los archivos.
USE [master] 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 
GO 

---Ahora si, ya puede ejecutar el resto.

USE Proyecto_Janus;
GO


-- Habilitar opciones avanzadas y consultas distribuidas ad hoc
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

CREATE OR ALTER PROCEDURE level2.insertarEmpleado @rutaArchivo NVARCHAR(255) 
AS
BEGIN
    DECLARE @direccion NVARCHAR(MAX);

    -- Crear tabla temporal para almacenar los datos importados
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
        turno VARCHAR(5)
    );

	PRINT @direccion;


    -- Construcción de la consulta dinámica para cargar datos en #tempEmpleado
    SET @direccion = N'SELECT * INTO #tempEmpleado FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
                   ''Excel 12.0; Database=' + @rutaArchivo + ''', [Empleados$])';

    -- Ejecutar la consulta dinámica
    EXEC sp_executesql @direccion;

    -- Insertar los registros únicos en la tabla 'empleado'
    INSERT INTO level2.empleado(id_empleado, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno)
		SELECT 
		t.id_empleado, t.nombre, t.apellido, t.dni, t.direccion, t.emailEmpresa, t.emailPersonal, t.cuil, t.cargo, t.sucursal, t.turno
		FROM #tempEmpleado t
		LEFT JOIN level2.empleado p ON t.id_empleado = p.id_empleado
		WHERE p.id_empleado IS NULL;
   ;
   select * from #tempEmpleado
   select * from level2.empleado


    -- Eliminar la tabla temporal
    DROP TABLE #tempEmpleado;
END;
GO

EXEC level2.insertarEmpleado N'C:\DDBBA\TP_integrador_Archivos\Informacion_complementaria.xlsx'
go
SELECT * FROM level2.empleado



exec level2.insertarArchivoEmpleado 'C:\DDBBA\TP_integrador_Archivos\Informacion_complementaria.xlsx'
go


--PRUEBA PARA FABRI Y CELESTE: si ejecuta este comando reemplazando la direccion del archivo leera el archivo. Mi icognita es que por alguna razon en el sp no carga los valores.
SELECT * 
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
    'Excel 12.0; Database=C:\DDBBA\TP_integrador_Archivos\Informacion_complementaria.xlsx', 
    [Empleados$]);

