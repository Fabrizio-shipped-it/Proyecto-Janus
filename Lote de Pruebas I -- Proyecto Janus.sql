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
--Resultado esperado: Solo debe existir la primera insersion

SELECT * FROM level1.sucursal 


-->Modificar

EXEC level1.modificarSucursal 'Tatooine', 'Palacio Hutt', 'Mar de Dunas del Norte', '2222-2222'
go
EXEC level1.modificarSucursal  'Tatooine', 'Palacio Hotter', 'Mar de Dunas del Norte', '2223-2222'
go

--Resultado esperado: Solo se modifica el primer valor

SELECT * FROM level1.sucursal



-->Eliminar

EXEC level1.borrarSucursal 'Palacio Hutt'
EXEC level1.borrarSucursal 'Templo Jedi'

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

EXEC level2.insertarUnEmpleado 257935, 'Edward', 'Richtofen', 90453233, 'Instalaciones de Der Riese', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '', 'Supervisor', 'Palacio Hutt', 'TM';
go
EXEC level2.insertarUnEmpleado 89, 'Samantha', 'Maxis', 111151115, 'Casa en Agatha', '', '', '', 'Stoomtroper', 'Palacio Hutt', 'TN';
go
EXEC level2.insertarUnEmpleado 257115, 'Ledwing', 'Maxis', 12, 'Kino der Toten', 'dereisendrache@grupo935.com', 'lmaxis@grupo935.com', '', 'Cajero', 'Placio Hutt', 'TM';
go
EXEC level2.insertarUnEmpleado 257115, 'Ledwing', 'Maxis', 12222222, 'Kino der Toten', 'dereisendrache@grupo935.com', 'lmaxis@grupo935.com', '', 'Comandante', 'Palacio Hutt', 'TM';
go
EXEC level2.insertarUnEmpleado 257115, 'Ledwing', 'Maxis', 12222222, 'Kino der Toten', 'dereisendrache@grupo935.com', 'lmaxis@grupo935.com', '', 'Cajero', 'Palacio Hutt', 'TM';
go



--Resultado esperado: solo debe existir la primera insercion y la ultima

SELECT * FROM level2.empleado 
go

-->Modificado
EXEC level2.modificarEmpleado 257935, 'Edward', 'Richtofen',  'Instalaciones del Puesto Griffin', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', 2, 1, 2, 'TN'
go
EXEC level2.modificarEmpleado 257935, 'Edward', 'Richtofen',  'Instalaciones del Puesto Griffin', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', 2, 'Cajero', 'Palacio Hutt', 'TM'
go
EXEC level2.modificarEmpleado 935, 'Edwara', 'Richtofenia',  'Instalaciones de Shino Numa', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '', 1, 1, 'TN'
go

-- Resultado esperado: Richtofen esta en el Puesto Griffin, con cuil 2, cargo cajero y en el turno TN.

SELECT * FROM level2.empleado 
go
--->Borrado

EXEC level2.borrarEmpleado 257935
go
EXEC level2.borrarEmpleado 257115
go
EXEC level2.borrarEmpleado 4
go
SELECT * FROM level2.empleado
go

--Resultado esperado: solo deberia borrar los tests


EXEC level2.reactivarEmpleado 257935
SELECT * FROM level2.empleado
go

--------------------------------PRODUCTO-------------------------------------------

-->Insertar

EXEC level1.insertarUnProducto 'Cubo de compania', 'Aperture Science', 43.3
GO
EXEC level1.insertarUnProducto 'Torreta', 'Half Life',  115.935
GO
EXEC level1.insertarUnProducto  'Cubo de compania', 'Aperture Science', 43.3
GO
EXEC level1.insertarUnProducto 'Cubo laser','Imperio Klingon',  89
GO
EXEC level1.insertarUnProducto  'GLaDOS', 'Aperture Science', -2323
GO


--Resultado esperado: Solo debe existir la torreta, el cubo de compania y el cubo laser
SELECT * FROM level1.producto


-->Modificado

EXEC level1.modificarProducto  1, 'Aperture Science', 78.9
GO
EXEC level1.modificarProducto 2, 'Half Life', 935.115
GO
EXEC level1.modificarProducto 1, 'Aperture Science',  -34
GO

--Resultado esperado: Solo los dos primeros tienen efecto

SELECT * FROM level1.producto
go
-->Borrado

EXEC level1.borrarProducto 2
GO
EXEC level1.borrarProducto 1
GO
EXEC level1.borrarProducto 3
GO

--Resultado esperado: borra los tests

SELECT * FROM level1.producto
go


