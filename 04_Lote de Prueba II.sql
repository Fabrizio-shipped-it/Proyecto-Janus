-------------------------------<Lote de Pruebas II>-----------------------------------------

/* 
fecha de entrega: 26/11/2024

-------------------<Introduccion>------------------------------------

-->En este script encontrara un pequeño test de login y rol.


-->Cumplimiento de consigna: Entrega 5
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7: Proyecto Janus


	DNI			DIRECTORES DEL PROYECTO
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE


---------[Indice]--------------
+   Creacion de Usuarios
+   Test de Rol

--------------------------------

*/

USE Com2900G07

--Creacion de usuarios

CREATE LOGIN Spock
WITH PASSWORD = 'Vulcano!', DEFAULT_DATABASE = Com2900G07,
CHECK_POLICY = ON, CHECK_EXPIRATION = OFF ;
CREATE USER Spock FOR LOGIN Spock

CREATE LOGIN CapKrik
WITH PASSWORD = 'Enterprise1966', DEFAULT_DATABASE = Com2900G07,
CHECK_POLICY = ON, CHECK_EXPIRATION = OFF ;
CREATE USER CapKrik FOR LOGIN CapKrik
GO

--Agrego los miembros a los roles
ALTER ROLE Supervisor ADD MEMBER Spock; 
ALTER ROLE Cajero ADD MEMBER CapKrik;
go

-----------
--TEST----
----------


EXECUTE as LOGIN = 'Spock'
EXEC level3.crearNotaCredito '226-31-3083', 5, 2, 'Vinieron para uso de Daleks'
GO

--Resultado esperado:
--  No hace falta que se inserte algo, ya se ha demostrado el funcionamiento del sp. Lo que importa es que no salta error.

EXECUTE AS LOGIN = 'CapKrik'
EXEC level3.crearNotaCredito '226-31-3083', 5, 2, 'Vinieron para uso de Daleks'
GO

--Resultado esperado:
--No debería de pasar nada

REVERT      --volver a ser admin 
go
