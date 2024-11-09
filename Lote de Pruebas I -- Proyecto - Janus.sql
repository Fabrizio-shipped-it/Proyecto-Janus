-----------------------------------------<LOTE DE PRUEBAS I>-----------------------------------------------
/* PRUEBAS DE LOS STORED PROCEDURES BASICOS

-->En este script contiene los lotes de pruebas de los SP basicos


-->Cumplimiento de consigna: Entrega 3
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7: Proyecto Janus


	DNI			DIRECTORES DEL PROYECTO
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE

*/


use Com2900G07
go

--------------------------------------SUCURSAL----------------------------------------------------------


-->Insertar

EXEC level1.insertarUnSucursal 'Tatooine', 'Palacio Hutt', 'arena de Oasis entre Mos Esly y Mos Espa', '1111-1111'
go
EXEC level1.insertarUnSucursal 'Kamino', '', 'Plataforma 115 en el medio del oceano', '1234-5678'
go
--Resultado esperado: Solo debe existir la primera insersion

SELECT * FROM level1.sucursal 


-->Modificar

EXEC level1.modificarSucursal 1, 'Tatooine', 'Palacio Hutt', 'Mar de Dunas del Norte', '2222-2222'
go
EXEC level1.modificarSucursal 2, 'Tatooine', 'Palacio Hotter', 'Mar de Dunas del Norte', '2223-2222'
go

--Resultado esperado: Solo se modifica el primer valor

SELECT * FROM level1.sucursal



-->Eliminar

EXEC level1.borrarSucursal 1
EXEC level1.borrarSucursal 2

--Resultado esperado: no haya errores al eliminarlo

SELECT * FROM level1.sucursal

-----------------------------------------CARGOS-------------------------------------------------

-->Insertar

EXEC level2.insertarCargo 4, 'Cientifico'
GO
EXEC level2.insertarCargo 2, 'Supervisor'
GO
EXEC level2.insertarCargo 1, 'Cientifico'
GO

SELECT * FROM level2.cargo

--Resultado esperado: solo debe haber un rol de supervisor (el existente predeterminado) y debe agregarse el cientifico

-->Borrar

EXEC level2.borrarCargo 4
go

SELECT * FROM level2.cargo

--Resultado Esperado: elimina al cientifico de la tabla

-----------------------------------------EMPLEADOS---------------------------------------------


--En caso de eliminar el test de Sucursal ejecutar y cambiar el valor idCatalogo al valor actual en la insersion de empleado:

EXEC level1.insertarUnSucursal 'Tatooine', 'Palacio Hutt', 'Mar de Dunas del Norte', '1111-1111'
go


-->Insertar

EXEC level2.insertarUnEmpleado 257935, 'Edward', 'Richtofen', 90453233, 'Instalaciones de Der Riese', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '', 1, 2, 'TM';
go
EXEC level2.insertarUnEmpleado 89, 'Samantha', 'Maxis', 111151115, 'Casa en Agatha', '', '', '', 2, 3, 'TN';
go
EXEC level2.insertarUnEmpleado 257115, 'Ledwing', 'Maxis', 12, 'Kino der Toten', 'dereisendrache@grupo935.com', 'lmaxis@grupo935.com', '', 1, 2, 'TM';
go
EXEC level2.insertarUnEmpleado 257115, 'Ledwing', 'Maxis', 12222222, 'Kino der Toten', 'dereisendrache@grupo935.com', 'lmaxis@grupo935.com', '', 4, 2, 'TM';
go



--Resultado esperado: solo debe existir la primera insercion

SELECT * FROM level2.empleado 
go

-->Modificado
EXEC level2.modificarEmpleado 257935, 'Edward', 'Richtofen',  'Instalaciones del Puesto Griffin', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '2', 1, 2, 'TN'
go
EXEC level2.modificarEmpleado 257935, 'Edward', 'Richtofen',  'Instalaciones del Puesto Griffin', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '', 2, 1, 'TM'
go
EXEC level2.modificarEmpleado 935, 'Edwara', 'Richtofenia',  'Instalaciones de Shino Numa', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '', 1, 1, 'TN'
go

-- Resultado esperado: Richtofen esta en el Puesto Griffin, con cul 2, idCargo 2 y en el turno TM.

SELECT * FROM level2.empleado 
go
--->Borrado

EXEC level2.borrarEmpleado 257935
go
EXEC level2.borrarEmpleado 4
go
SELECT * FROM level2.empleado
go

--Resultado esperado: solo deberia borrar el id 2




---------------------------CATALOGO-------------------------------

-->Insertar

EXEC level1.insertarCatalogo 'Limpieza'
GO
EXEC level1.insertarCatalogo 'Limpieza'
GO
EXEC level1.insertarCatalogo 'Verduras'
GO

--Resultado esperado: Solo debe haber un catalogo limpieza y verduras

SELECT * FROM level1.catalogo

-->Modificar

EXEC level1.modificarCatalogo 1, 'Limpieza marca ACME'
GO
EXEC level1.modificarCatalogo 2, 'Verduras'
GO

--Resultado esperado: Solo debe haberse actualizado el catalogo de limpieza

SELECT * FROM level1.catalogo


-->Borrado

EXEC level1.borrarCatalogo 1
GO
EXEC level1.borrarCatalogo 2
GO

--Resultado esperado: Borrado todo

SELECT * FROM level1.catalogo
go

--------------------------------PRODUCTO-------------------------------------------

--- Corregir modificado y probar borrado
--- Hacer los sp de Modo de pago y ventaRegistrada 

--En caso de que elimino los test de catalogo ejecutar y actualizar el valor de idCatalogo en la insersion de productos:

EXEC level1.insertarCatalogo 'Limpieza'
GO
EXEC level1.insertarCatalogo 'Verduras'
GO

-->Insertar

EXEC level1.insertarUnProducto 3, 'Cubo de compania', 43.3
GO
EXEC level1.insertarUnProducto 4, 'Torreta', 115.935
GO
EXEC level1.insertarUnProducto 3, 'Cubo de compania', 43.3
GO
EXEC level1.insertarUnProducto 5, 'Cubo laser', 89
GO
EXEC level1.insertarUnProducto 3, 'GLaDOS', -2323
GO


--Resultado esperado: Solo debe existir la torreta y el cubo de compania
SELECT * FROM level1.producto


-->Modificado

EXEC level1.modificarProducto  1, 4, 78.9
GO
EXEC level1.modificarProducto 2, 4, 935.115
GO
EXEC level1.modificarProducto 1, 4,  -34
GO

--Resultado esperado: Solo los dos primeros tienen efecto

SELECT * FROM level1.producto
go
-->Borrado

EXEC level1.borrarProducto 2
GO
EXEC level1.borrarProducto 1
GO

--Resultado esperado: borra los tests

SELECT * FROM level1.producto
go


---------------------------------MEDIO DE PAGO--------------------------------------------------


--->Insertar Medio Pago


EXEC level2.insertarMedioPago 4, 'Creditos Imperiales', 'Imperial Credits'
GO

SELECT * FROM level2.medioPago 

-->Eliminar Medio Pago

EXEC level2.eliminarMedioPago 4

SELECT * FROM level2.medioPago


------------------------------------- Ventas Registrada------------------------------


--Funcion Buscar Precio

--En caso de haber eliminado los lotes de prueba de productos, insertarlos 
EXEC level1.insertarUnProducto 3, 'Cubo de compania', 43.3
GO
EXEC level1.insertarUnProducto 4, 'Torreta', 115.935
GO

SELECT * FROM level1.producto
go

DECLARE @test DECIMAL(10,2) = level2.buscarPrecioProducto ('Torreta')


print('Precio de la torreta: ' + cast(@test AS VARCHAR(10)))
go



-->Insercion VentasRegistrada

 


-- Ejecutar estos comandos en caso de que haya eliminado los tests anteriores (actualizar los valores de id)
EXEC level1.insertarUnProducto 4, 'Torreta', 115.935
GO
EXEC level2.insertarUnEmpleado 257935, 'Edward', 'Richtofen', 90453233, 'Instalaciones de Der Riese', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '', 1, 5, 'TM';
go
EXEC level1.insertarUnSucursal 'Tatooine', 'Palacio Hutt', 'arena de Oasis entre Mos Esly y Mos Espa', '1111-1111'
go


SELECT * FROM level1.producto
SELECT * FROM level1.catalogo
select * from level2.empleado
SELECT * FROM level1.sucursal
SELECT * FROM level2.medioPago
go

-- El test comienza aqui

EXEC level2.insertarUnaVentaRegistrada '111-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Wookye', 'Torreta', 2, '2002-07-24', '9:32', 'Cash', '0000-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '111-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Wookye', 'Torreta', 2, '2002-07-24', '9:32', 'Cash', '0000-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '112-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Wookye', 'Torreta', 2, '2002-07-24', '9:32', 'Cash', '0000-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '111-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Wookye', 'Torreta', 2, '2002-07-24', '9:32', 'Cash', '0002-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '112-111-111', 'A', 'Palacio Hutter', 'Wookye', 'Wookye', 'Torreta', 2, '2002-07-24', '9:32', 'Cash', '0002-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '112-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Wookye', 'Torreta de Half Life', 2, '2002-07-24', '9:32', 'Cash', '0002-935-115', 257935
go
EXEC level2.insertarUnaVentaRegistrada '112-111-111', 'A', 'Palacio Hutt', 'Wookye', 'Wookye', 'Torreta', 2, '2002-07-24', '9:32', 'creditos de la Federacion', '0002-935-115', 257935
go

SELECT * from level2.ventaRegistrada

--Resultado esperado: Se ha ejecutado duplicados e insercion de valores incorrectos. Solo debe existir un valor: 
--111-111-111	A	Tatooine	Wookye	Wookye	Torreta	115.94 2	2002-07-24	09:32:00	Cash	0000-935-115	257935	Palacio Hutt	289.85

-->Borrado

EXEC level2.eliminarVentaRegistrada 1
go

SELECT * from level2.ventaRegistrada
go

-->Limpieza de test

EXEC level1.borrarSucursal 5
EXEC level2.borrarEmpleado 257935
EXEC level1.borrarCatalogo 3
EXEC level1.borrarCatalogo 4
EXEC level1.borrarProducto 3
EXEC level1.borrarProducto 4
go
