-- Aqui les hice dos procedures que muestran lo pedido. No esta en modo XML pero al menos la logica creo que sería esa. 
-- Las otras ni idea de como hacer. Si alguien es mago casteando este es su momento. 

-- De paso les dejo la lista de pendientes del proyecto:
-- IMPORTANTE: Reportes de todo tipo. Tengo entendido que solo hace falta mostrarlo en formato XML.
--             Hacer el lote de pruebas de NotaCredito (Lo hago yo, me re olvide la verdad de hacerlo).
-- RECOMENDABLE: Testear todo el proyecto. Yo lo he testeado, pero mejor encontrar bugs entre nosotros que en el coloquio.
--               Asegurarnos que todo el formato del proyecto cumpla la consigna.

-- La verdad no mucho mas, no se me ocurre otra cosa que quede pendiente. Lamentablemente tenemos hasta antes de las 19 para 
-- hacer todo y entregarlo (Segun lo que dijo Jair), así que nos deseo muchos animos y fuerzas porque en menos de 24 horas 
-- vemos si vamos a final (ya que tambien confirmo que todos vamos a final pase lo que pase) o tendremos que recursarla. 


use Com2900G07
go

CREATE OR ALTER PROCEDURE level2.reporteFechaCantidadProductos @fechaInicio DATETIME, @fechaFin DATETIME AS
BEGIN

    SELECT p.nombreProducto, SUM(cantidad) AS cantidadVendida
    FROM level2.detalleVenta d INNER JOIN level1.producto p ON d.idProducto = p.idProducto
    WHERE iD_Venta IN (SELECT iD_Venta FROM level2.factura f WHERE (f.fechaHora BETWEEN @fechaInicio AND @fechaFin) AND (f.estado = 'Pagada')) 
    GROUP BY p.nombreProducto
    ORDER BY cantidadVendida DESC


END
go


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
END
GO


EXEC level2.reporteFehaProdVendidosPorSucursal '2023-11-26', '2024-12-25'
EXEC level2.reporteFechaCantidadProductos '2023-11-26', '2024-12-25'


CREATE OR ALTER PROCEDURE level2.TotalFacturadoPorDiaSemana
    @mes INT,
    @anio INT
AS
BEGIN
    -- Validación del mes válido
    IF @mes > 1 OR @mes < 12
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
			GROUP BY DATENAME(WEEKDAY, f.fechaHora) --Agrupa los resultados por día de la semana para calcular el total facturado de cada día.
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
			END;
    END;
	ELSE
	BEGIN
		PRINT 'El mes debe estar entre 1 y 12.';
	END
END;
GO
drop procedure level2.TotalFacturadoPorDiaSemana
EXEC level2.TotalFacturadoPorDiaSemana 1, 2019;
--------------------------------------------------<<XML>>--------------------------------------------------
CREATE OR ALTER PROCEDURE level2.TotalFacturadoPorDiaSemanaXML
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
drop procedure level2.TotalFacturadoPorDiaSemanaXML
EXEC level2.TotalFacturadoPorDiaSemanaXML 1, 2019;
