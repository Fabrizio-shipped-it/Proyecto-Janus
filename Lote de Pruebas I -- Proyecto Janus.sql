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


IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com2900G07')
BEGIN
    print('Debe ejecutar el script de creacion de tablas y sq para poder usar este script')
END;

use Com2900G07
go

--------------------------------------SUCURSAL----------------------------------------------------------
-->Insertar

EXEC level1.insertarUnSucursal 'Tatooine', 'Palacio Hutt', 'arena de Oasis entre Mos Esly y Mos Espa', '1111-1111'
go
EXEC level1.insertarUnSucursal 'Kamino', '', 'Plataforma 115 en el medio del oceano', '1234-5678'
go
--Resultado esperado: 

-- 1    Tatooine    Palacio Hutt     arena de Oasis entre Mos Esly y Mos Espa    1111-1111  20-22222222-3

SELECT * FROM level1.sucursal 


-->Modificar

EXEC level1.modificarSucursal 1, 'Tatooine', 'Palacio Hutt', 'Mar de Dunas del Norte', '2222-2222', '20-22222222-3'
go
EXEC level1.modificarSucursal  2, 'Tatooine', 'Palacio Hotter', 'Mar de Dunas del Norte', '2223-2222', '20-22222222-3'
go

--Resultado esperado: 
-- 1    Tatooine    Palacio Hutt     Mar de Dunas del Norte   2222-2222  20-22222222-3

SELECT * FROM level1.sucursal



-->Eliminar

EXEC level1.borrarSucursal 'Palacio Hutt'
EXEC level1.borrarSucursal 'Templo Jedi'

--Resultado esperado: 

-- 

SELECT * FROM level1.sucursal



-----------------------------------------CARGOS-------------------------------------------------

-->Insertar

EXEC level2.insertarCargo 4, 'Cientifico'
GO
EXEC level2.insertarCargo 1, 'Supervisor'
GO
EXEC level2.insertarCargo 1, 'Cientifico'
GO
EXEC level2.insertarCargo 5, 'Supervisor'
GO

SELECT * FROM level2.cargo

--Resultado esperado: 

-- 4    Cientifico
-- 1    Supervisor

-->Borrar

EXEC level2.borrarCargo 2
go
EXEC level2.borrarCargo 3
go
EXEC level2.borrarCargo 4
go

SELECT * FROM level2.cargo

--Resultado Esperado: 

--


-----------------------------------------EMPLEADOS---------------------------------------------


--En caso de eliminar el test de Sucursal ejecutar y cambiar el valor idCatalogo al valor actual en la insersion de empleado:

EXEC level1.insertarUnSucursal 'Tatooine', 'Palacio Hutt', 'Mar de Dunas del Norte', '1111-1111'
go
EXEC level2.insertarCargo 4, 'Cientifico'
GO

-->Insertar

EXEC level2.insertarUnEmpleado  'Edward', 'Richtofen', 90453233, 'Instalaciones de Der Riese', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '', 'Cientifico', 'Palacio Hutt', 'TM';
go
EXEC level2.insertarUnEmpleado  'Samantha', 'Maxis', 111151115, 'Casa en Agatha', '', '', '', 'Stoomtroper', 'Palacio Hutt', 'TN';
go
EXEC level2.insertarUnEmpleado  'Ledwing', 'Maxis', 12, 'Kino der Toten', 'dereisendrache@grupo935.com', 'lmaxis@grupo935.com', '', 'Cajero', 'Placio Hutt', 'TM';
go
EXEC level2.insertarUnEmpleado  'Ledwing', 'Maxis', 12222222, 'Kino der Toten', 'dereisendrache@grupo935.com', 'lmaxis@grupo935.com', '', 'Comandante', 'Palacio Hutt', 'TM';
go
EXEC level2.insertarUnEmpleado  'Ledwing', 'Maxis', 12222222, 'Kino der Toten', 'dereisendrache@grupo935.com', 'lmaxis@grupo935.com', '', 'Cientifico', 'Palacio Hutt', 'TM';
go



--Resultado esperado: 

-- Edward   Richtofen   90453233    Instalaciones de Der Riese  dereisendrache@grupo935.com     erichtofen@grupo935.com  '' 
-- Cientifico   Palacio Hutt     TM 1

-- Ledwing   Maxis  12222222    Kino der Toten  dereisendrache@grupo935.com     lmaxis@grupo935.com  ''
--  Cientifico  Palacio Hutt    TM  1

SELECT * FROM level2.empleado 
go

-->Modificado
EXEC level2.modificarEmpleado 257020, 'Edward', 'Richtofen',  'Instalaciones del Puesto Griffin', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', 2, 'Cientifico', 'Palacio Hutt', 'TN'
go
EXEC level2.modificarEmpleado 257022, 'Edward', 'Richtofen',  'Instalaciones del Puesto Griffin', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', 2, 'Cajero', 'Palacio Hutt', 'TM'
go
EXEC level2.modificarEmpleado 935, 'Edwara', 'Richtofenia',  'Instalaciones de Shino Numa', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '', 1, 1, 'TN'
go

-- Resultado esperado

-- Edward   Richtofen   90453233    Instalaciones del Puesto Griffin  dereisendrache@grupo935.com     erichtofen@grupo935.com  2 
-- Cientifico   Palacio Hutt     TM 1

-- Ledwing   Maxis  12222222    Kino der Toten  dereisendrache@grupo935.com     lmaxis@grupo935.com  ''
--  Cientifico  Palacio Hutt    TM  1

SELECT * FROM level2.empleado 
go

--->Dar de baja al empleado

EXEC level2.bajarEmpleado 257020
go
EXEC level2.bajarEmpleado 257021
go
EXEC level2.bajarEmpleado 4
go
SELECT * FROM level2.empleado
go

--Resultado esperado: 
-- Edward   Richtofen   90453233    Instalaciones del Puesto Griffin  dereisendrache@grupo935.com     erichtofen@grupo935.com  2 
-- Cientifico   Palacio Hutt     TM     0

-- Ledwing   Maxis  12222222    Kino der Toten  dereisendrache@grupo935.com     lmaxis@grupo935.com  ''
--  Cientifico  Palacio Hutt    TM      0

-->Reactivar empleado

EXEC level2.reactivarEmpleado 257020
SELECT * FROM level2.empleado
go

--Resultado esperado: 
-- Edward   Richtofen   90453233    Instalaciones del Puesto Griffin  dereisendrache@grupo935.com     erichtofen@grupo935.com  2 
-- Cientifico   Palacio Hutt     TM     1

-- Ledwing   Maxis  12222222    Kino der Toten  dereisendrache@grupo935.com     lmaxis@grupo935.com  ''
--  Cientifico  Palacio Hutt    TM      0
EXEC level2.bajarEmpleado 257020
go


--------------------------------PRODUCTO-------------------------------------------

-->Insertar

EXEC level1.insertarUnProducto 'Cubo de compania', 'Aperture Science', 43.3, 'unidad'
GO
EXEC level1.insertarUnProducto 'Torreta', 'Black Mesa',  115.935, 'unidad'
GO
EXEC level1.insertarUnProducto  'Cubo de compania', 'Aperture Science', 43.3, 'unidad'
GO
EXEC level1.insertarUnProducto 'Cubo laser','Imperio Klingon',  89, 'klingons'
GO
EXEC level1.insertarUnProducto  'GLaDOS', 'Aperture Science', -2323, 'kilos'
GO


--Resultado esperado: 
-- 1    Aperture Science    Cubo de Compania    43.30   unidad  1
-- 2    Black Mesa  115.935 unidad  1
-- 2    Imperio Klingon Cubo laser  89  klingons    1

SELECT * FROM level1.producto


-->Modificado

EXEC level1.modificarProducto  1, 'Aperture Science', 78.9
GO
EXEC level1.modificarProducto 2, 'Half Life', 935.115
GO
EXEC level1.modificarProducto 1, 'Aperture Science',  -34
GO

--Resultado esperado:
-- 1    Aperture Science    Cubo de Compania    78.90   unidad  1
-- 2    Black Mesa  935.2 unidad  1
-- 3    Imperio Klingon Cubo laser  89  klingons    1


SELECT * FROM level1.producto
go

-->Dar de baja Producto

EXEC level1.bajarProducto 1
go
EXEC level1.bajarProducto 2
go


--Resultado esperado:
-- 1    Aperture Science    Cubo de Compania    78.90   unidad  0
-- 2    Black Mesa  935.2 unidad  0
-- 3    Imperio Klingon Cubo laser  89  klingons    1

SELECT * FROM level1.producto
go

-->Dar de alta producto

EXEC level1.reactivarProducto 1
go

--Resultado esperado:
-- 1    Aperture Science    Cubo de Compania    78.90   unidad  1
-- 2    Black Mesa  935.2 unidad  0
-- 3    Imperio Klingon Cubo laser  89  klingons    1

SELECT * FROM level1.producto
go


EXEC level1.bajarProducto 1
go
EXEC level1.bajarProducto 2
go
EXEC level1.bajarProducto 3
go




