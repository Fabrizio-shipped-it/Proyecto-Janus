-------------------------------------------------<REPORTES>-----------------------------------------

/* 

fecha: 26/11/2024

==========================================<Introduccion>===================================================================

-->En este script estaran los SP que mostraran los diferentes reportes en formato XML


-->Cumplimiento de consigna: Entrega 3-4
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7: Proyecto Janus


	DNI			DIRECTORES DEL PROYECTO
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE


=================================================<Indice>===================================================================

+ SP DE REPORTES

========================================================================================================================
*/
use Com2900G07
go

--Reporte ingresando intervalo de fecha muestra productos vendidos por sucursal

CREATE OR ALTER PROCEDURE level2.reporteFehaProdVendidosPorSucursal ( @FechaInicio DATETIME ,@FechaFin DATETIME )
AS
BEGIN
    SELECT s.nombreSucursal, p.nombreProducto, SUM(d.cantidad) AS CantidadVendida
    FROM level2.detalleVenta d
    INNER JOIN level1.producto p ON d.idProducto = p.idProducto
    INNER JOIN level2.factura f ON f.iD_Venta = d.iD_Venta
    INNER JOIN level1.sucursal s ON f.iD_Sucursal = s.idSucursal
    WHERE (f.fechaHora BETWEEN @FechaInicio AND @FechaFin) AND (f.estado = 'Pagada')
    GROUP BY s.nombreSucursal, p.nombreProducto
    ORDER BY s.nombreSucursal, CantidadVendida DESC
    FOR XML AUTO, ELEMENTS
END
GO

--Reporte ingresando intervalo de fechas muestra cantidad por producto vendida

CREATE OR ALTER PROCEDURE level2.reporteFechaCantidadProductos @fechaInicio DATETIME, @fechaFin DATETIME AS
BEGIN

    SELECT p.nombreProducto, SUM(cantidad) AS cantidadVendida
    FROM level2.detalleVenta d INNER JOIN level1.producto p ON d.idProducto = p.idProducto
    WHERE iD_Venta IN (SELECT iD_Venta FROM level2.factura f WHERE (f.fechaHora BETWEEN @fechaInicio AND @fechaFin) AND (f.estado = 'Pagada')) 
    GROUP BY p.nombreProducto
    ORDER BY cantidadVendida DESC
    FOR XML AUTO, ELEMENTS
END
go



--Reporte con los cinco productos mas vendidos de la fecha

CREATE OR ALTER PROCEDURE level2.reporteCincoProdMasVendidos @mes INT, @anio INT AS
    BEGIN
    
        SELECT DATEPART(WEEK, f.fechaHora) AS Semana,
               p.nombreProducto,
               SUM(d.cantidad) AS CantidadVendida
        FROM level2.detalleVenta d
        INNER JOIN level1.producto p ON d.idProducto = p.idProducto
        INNER JOIN level2.factura f ON f.iD_Venta = d.iD_Venta
        WHERE MONTH(f.fechaHora) = @Mes AND YEAR(f.fechaHora) = @Anio
        GROUP BY DATEPART(WEEK, f.fechaHora), p.nombreProducto
        ORDER BY Semana, CantidadVendida DESC OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY
        FOR XML AUTO, ELEMENTS
        

    END
go

-- Reporte de los cinco productos menos vendidos por fecha

CREATE OR ALTER PROCEDURE level2.reporteCincoProductosMenosVendidos @mes INT, @anio INT AS
    BEGIN
        SELECT p.nombreProducto,
               SUM(dv.cantidad) AS CantidadVendida
        FROM level2.detalleVenta dv
        INNER JOIN level1.producto p ON dv.idProducto = p.idProducto
        INNER JOIN level2.factura f ON f.iD_Venta = dv.iD_Venta
        WHERE MONTH(f.fechaHora) = @Mes AND YEAR(f.fechaHora) = @Anio
        GROUP BY p.nombreProducto
        ORDER BY CantidadVendida ASC
        OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY
        FOR XML AUTO, ELEMENTS
    END
go

--Reporte total de venta acumulados por sucursal en una fecha

CREATE OR ALTER PROCEDURE level2.reporteTotalAcumuloVentas @fecha DATETIME, @idSucursal INT AS
    BEGIN
        SELECT f.iD_Factura,
               f.fechaHora,
               s.nombreSucursal,
               SUM(dv.cantidad * dv.precioUnitario) AS TotalFactura
        FROM level2.factura f
        INNER JOIN level2.detalleVenta dv ON f.iD_Venta = dv.iD_Venta
        INNER JOIN level1.sucursal s ON f.iD_Sucursal = s.idSucursal
        WHERE CAST(f.fechaHora AS DATE) = @Fecha AND s.idSucursal = @idSucursal
        GROUP BY f.iD_Factura, f.fechaHora, s.nombreSucursal
        FOR XML AUTO, ELEMENTS
    END
go

--------------------------------------------------<<XML>>--------------------------------------------------
CREATE OR ALTER PROCEDURE level2.reporteTotalFacturadoPorDiaSemanaXML
    @mes INT,
    @anio INT
AS
BEGIN
    -- Validación del mes válido
    IF @mes BETWEEN 1 AND 12
    BEGIN
        -- Consulta para calcular el total facturado por día de la semana
        WITH Totales AS (
            SELECT 
                DATENAME(WEEKDAY, f.fechaHora) AS DiaSemana, -- Nombre del día de la semana
                SUM(vr.total_IVA) AS TotalFacturado 
            FROM level2.factura f
            INNER JOIN level2.ventaRegistrada vr ON f.iD_Venta = vr.iD_Venta
            WHERE 
                MONTH(f.fechaHora) = @mes
                AND YEAR(f.fechaHora) = @anio
                AND f.estado = 'PAGADA'
            GROUP BY DATENAME(WEEKDAY, f.fechaHora) -- Agrupa los resultados por día de la semana
        )
        SELECT 
            DiaSemana,
            ISNULL(TotalFacturado, 0) AS TotalFacturado
        FROM 
            Totales
        ORDER BY 
            CASE 
                WHEN DiaSemana = 'Monday' THEN 1
                WHEN DiaSemana = 'Tuesday' THEN 2
                WHEN DiaSemana = 'Wednesday' THEN 3
                WHEN DiaSemana = 'Thursday' THEN 4
                WHEN DiaSemana = 'Friday' THEN 5
                WHEN DiaSemana = 'Saturday' THEN 6
                WHEN DiaSemana = 'Sunday' THEN 7
            END
        FOR XML PATH('Dia'), ROOT('Totales'), ELEMENTS;
    END;
    ELSE
    BEGIN
        PRINT 'El mes debe estar entre 1 y 12.';
    END
END;
GO

CREATE OR ALTER PROCEDURE level2.reporteTrimestralXML
    @trimestre INT,
    @anio INT
AS
BEGIN
    -- Consulta principal con clasificación por turno de trabajo
    SELECT
       MONTH( f.fechaHora) AS Mes,
        CASE 
            WHEN DATEPART(HOUR, f.fechaHora) BETWEEN 0 AND 12 THEN 'Turno Mañana' ELSE 'Turno Tarde'
        END AS TurnoTrabajo,

         SUM(vr.total_IVA) AS TotalFacturado 
         FROM level2.factura f
         INNER JOIN level2.ventaRegistrada vr ON f.iD_Venta = vr.iD_Venta
    WHERE 
        YEAR( f.fechaHora) = @anio
        AND (
            (@trimestre = 1 AND MONTH( f.fechaHora) BETWEEN 1 AND 3) OR
            (@trimestre = 2 AND MONTH( f.fechaHora) BETWEEN 4 AND 6) OR
            (@trimestre = 3 AND MONTH( f.fechaHora) BETWEEN 7 AND 9) OR
            (@trimestre = 4 AND MONTH( f.fechaHora) BETWEEN 10 AND 12)
        )
    GROUP BY MONTH( f.fechaHora), 
             CASE 
                 WHEN DATEPART(HOUR, f.fechaHora) BETWEEN 0 AND 12 THEN 'Turno Mañana'
                 ELSE 'Turno Tarde'
             END
    FOR XML PATH('Turno'), ROOT('ReporteTrimestral'), ELEMENTS;
END;
GO

/*
EXEC level2.ReporteTrimestralXML 11, 2024	--le faltan datos

EXEC level2.reporteTotalFacturadoPorDiaSemanaXML 11, 2024	--Mes y año

EXEC level2.reporteFehaProdVendidosPorSucursal '2023-11-25', '2024-12-25'	--Rango fechas

EXEC level2.reporteFechaCantidadProductos '2023-11-25', '2024-12-25'	--Rango fechas

EXEC level2.reporteCincoProdMasVendidos 11, 2024	--Mes y año

EXEC level2.reporteCincoProductosMenosVendidos 11, 2024	--Mes y año

EXEC level2.reporteTotalAcumuloVentas '2024-11-26', 1	--Fecha actual y numero de sucursal


select * from level2.factura
*/
