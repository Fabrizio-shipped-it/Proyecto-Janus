-----------------------------------------<LOTE DE PRUEBAS>-----------------------------------------------
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

EXEC level1.modificarSucursal 21, 'Tatooine', 'Palacio Hutt', 'Mar de Dunas del Norte', '2222-2222'
go
EXEC level1.modificarSucursal 33, 'Tatooine', 'Palacio Hotter', 'Mar de Dunas del Norte', '2223-2222'
go

--Resultado esperado: Solo se modifica el primer valor

SELECT * FROM level1.sucursal



-->Eliminar

EXEC level1.borrarSucursal 21
EXEC level1.borrarSucursal 24

--Resultado esperado: no haya errores. (No existe sucursal 24 y el 21 sera eliminado)

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

--Resultado esperado: solo debe haber un rol de supervisor

-->Borrar

EXEC level2.borrarCargo 4
go

SELECT * FROM level2.cargo

-----------------------------------------EMPLEADOS---------------------------------------------

-->Insertar

EXEC level2.insertarUnEmpleado 257935, 'Edward', 'Richtofen', 90453233, 'Instalaciones de Der Riese', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '', 1, 1, 'TM';
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
EXEC level2.modificarEmpleado 257935, 'Edward', 'Richtofen',  'Instalaciones del Puesto Griffin', 'dereisendrache@grupo935.com', 'erichtofen@grupo935.com', '2', 1, 1, 'TN'
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

EXEC level1.modificarCatalogo 1, 'Limpieza'
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


--------------------------------PRODUCTO-------------------------------------------

--- Corregir modificado y probar borrado
--- Hacer los sp de Modo de pago y ventaRegistrada 


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

EXEC level1.modificarProducto 1, 4, 'Cubo de compania', '43.30'
GO
EXEC level1.modificarProducto 2, 4, 'Torreta', '95.115'
GO
EXEC level1.modificarProducto 1, 4, 'Cubo de compania', '-34'
GO

--Resultado esperado: Solo los dos primeros tienen efecto

SELECT * FROM level1.producto


