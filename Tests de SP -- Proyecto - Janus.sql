--------LOTE DE PRUEBAS----------
use Proyecto_Janus
go

----EMPLEADOS-----------

-->Insertar

EXEC level2.insertarUnEmpleado 1, 's', 'm', 1111, 'a', 'b', 'c', 's', 'Supervisor', 'cat', 'TM';
go
EXEC level2.insertarUnEmpleado 1, 's', 'm', 1112, 'a', 'b', 'c', 's', 'Supervisor', 'cat', 'TM';
go
EXEC level2.insertarUnEmpleado 2, 'c', 't', 1113, 'a', 'b', 'c', 's', 'Supervisor', 'cat', 'TM';
go
EXEC level2.insertarUnEmpleado 3, 'f', 'g', 1113, 'a', 'b', 'c', 's', 'Supervisor', 'cat', 'TM';
go
EXEC level2.insertarUnEmpleado 2, 'c', 't', 1113, 'a', 'b', 'c', 's', 'Supervisor', 'cat', 'TM';
go
--Resultado esperado: solo debe existir la primera y tercera incersion
SELECT * FROM level2.empleado where id_empleado = 1 or id_empleado = 2 or id_empleado = 3
go

-->Modificado
EXEC level2.modificarEmpleado 1, 's', 's',  'd', 'e', 'f', 's', 'Supervisor', 'cat', 'TM'
go
EXEC level2.modificarEmpleado 2, 'c', 't',  'a', 'b', 'c', 's', 'Stoomtroper', 'cat', 'TN'
go
EXEC level2.modificarEmpleado 3, 'c', 't', 'a', 'b', 'c', 's', 'Stoomtroper', 'cat', 'TN'
go

-- Resultado esperado: el primer ejecutable debe modificar el apellido,  direccion y emails
--						el segundo ejecutable debe modificar cargo y turno	
--						debe saltar error con el tercer ejecutable

SELECT * FROM level2.empleado where id_empleado = 1 or id_empleado = 2 or id_empleado = 3
go
--->Borrado

EXEC level2.borrarEmpleado 2
go
EXEC level2.borrarEmpleado 4
go
SELECT * FROM level2.empleado where id_empleado = 1 or id_empleado = 2 or id_empleado = 3
go

--Resultado esperado: solo deberia borrar el id 2

EXEC level2.borrarEmpleado 1


