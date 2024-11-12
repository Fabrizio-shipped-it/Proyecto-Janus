-----------------------------------------<LOTE DE PRUEBAS II>-----------------------------------------------
/* PRUEBAS DE LOS STORED PROCEDURES VENTAS

-->En este script contiene los lotes de pruebas de los SP de ventas


-->Cumplimiento de consigna: Entrega 3
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7: Proyecto Janus


	DNI			DIRECTORES DEL PROYECTO
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE

*/


IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com2900G07')
BEGIN
    print('Debe ejecutar el script de creacion de tablas y sq, y el de creacion de tablas y sq ventas para poder usar este script')
END;

use Com2900G07
go

------------------------------------- Ventas Registrada------------------------------


--Funcion Buscar Precio

--En caso de haber eliminado los lotes de prueba de productos, insertarlos 
EXEC level1.insertarUnProducto 'Cubo de compania', 'Aperture Science' ,43.3
GO
EXEC level1.insertarUnProducto  'Torreta','Half Life', 115.935
GO

SELECT * FROM level1.producto
go

DECLARE @test DECIMAL(10,2) = level2.buscarPrecioProducto ('Torreta')


print('Precio de la torreta: ' + cast(@test AS VARCHAR(10)))
go



-->Insercion VentasRegistrada

 


-- Ejecutar estos comandos en caso de que haya eliminado los tests anteriores (actualizar los valores de id)
EXEC level1.insertarUnSucursal 'Tatooine', 'Palacio Hutt', 'arena de Oasis entre Mos Esly y Mos Espa', '1111-1111'
go
EXEC level2.reactivarEmpleado 257935
go
EXEC level1.insertarUnProducto 'Cubo de compania', 'Aperture Science' ,43.3
GO
EXEC level1.insertarUnProducto  'Torreta','Half Life', 115.935
GO



SELECT * FROM level1.producto
select * from level2.empleado
SELECT * FROM level1.sucursal
go

-- El test comienza aqui



EXEC level2.insertarUnaVentaRegistrada '111-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Hombre', 'Torreta', 2, '2002-07-24 9:32', 'Cash', '0000-935-115', 257935
go

EXEC level2.insertarUnaVentaRegistrada '111-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Mujer', 'Torreta', 2, '2002-07-24 9:32', 'Cash', '0000-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '112-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Hombre', 'Torreta', 2, '2002-07-24 9:32', 'Cash', '0000-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '111-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Mujer', 'Torreta', 2, '2002-07-24 9:32', 'Cash', '0002-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '112-111-111', 'A', 'Palacio Hutter', 'Wookye', 'Wookye', 'Torreta', 2, '2002-07-24 9:32', 'Cash', '0002-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '112-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Mujer', 'Torreta de Half Life', 2, '2002-07-24 9:32', 'Cash', '0002-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '112-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Wookye', 'Torreta', 2, '2002-07-24 9:32', 'creditos de la Federacion', '0002-935-115', 257935
go

EXEC level2.insertarUnaVentaRegistrada '111-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Hombre', 'Cubo de compania', 2, '2002-07-24 9:32', 'Cash', '0000-935-115', 257935
go
SELECT * from level2.ventaRegistrada

SELECT * FROM level2.detalleVenta

--Resultado esperado: 
--111-111-111	A	Tatooine	Wookye	Hombre	Torreta	115.94 2	2002-07-24 09:32:00	Cash	0000-935-115	257935	Palacio Hutt
--111-111-111	A	Tatooine	Wookye	Mujer	Torreta	115.94 2	2002-07-24 09:32:00	Cash	0000-935-115	257935	Palacio Hutt
--112-111-111	A	Tatooine	Wookye	Hombre	Torreta	115.94 2	2002-07-24 09:32:00	Cash	0000-935-115	257935	Palacio Hutt
--111-111-111	A	Tatooine	Wookye	Mujer	Torreta	115.94 2	2002-07-24 09:32:00	Cash	0000-935-115	257935	Palacio Hutt
--111-111-111	A	Tatooine	Wookye	Hombre	Cubo de compania	43.30 2	2002-07-24 09:32:00	Cash	0000-935-115	257935	Palacio Hutt

--Resultado esperado:
--111-111-111	A	Tatooine	Wookye Cash	257935	Palacio Hutt 782.24 4
--112-111-111	A	Tatooine	Wookye Cash	257935	Palacio Hutt 231.88 1

-->Borrado

EXEC level2.eliminarVentaRegistrada 1
go

EXEC level2.eliminarVentaRegistrada 2
go

EXEC level2.eliminarVentaRegistrada 3
go

EXEC level2.eliminarVentaRegistrada 4
go

EXEC level2.eliminarVentaRegistrada 5
go

SELECT * from level2.ventaRegistrada
go

--El detalle Venta no debe verse afectado por cambios de la base de datos, es una entidad independiente
SELECT * FROM level2.detalleVenta


-->Limpieza de test

EXEC level2.eliminarDetalleVenta '111-111-111'
exec level2.eliminarDetalleVenta '112-111-111'
EXEC level1.borrarSucursal 'Palacio Hutt'
EXEC level2.borrarEmpleado 257935
EXEC level1.borrarProducto 3
EXEC level1.borrarProducto 4
go

