-------------------------------<CREACION DE TABLAS Y STORED PROCEDURES BASICOS>-----------------------------------------

/* 


-------------------<Introduccion>------------------------------------

-->En este script estara a su disposición la creación de los roles y privilegios, y de la encriptación de tabla empleado


-->Cumplimiento de consigna: Entrega 5
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7: Proyecto Janus


	DNI			DIRECTORES DEL PROYECTO
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE


---------[Indice]--------------
+   Creacion de Rols y Usuarios
+   Tests de Rol Supervisor
+   Creacion de la llave
+   SP de encriptado y desencriptado
+   Pruebas

--------------------------------


*/

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com2900G07')
BEGIN
    print('Debe ejecutar el script de creacion de tablas y sq para poder usar este script')
END;


USE Com2900G07
GO


-----------------------<CREACION DE ROLES Y USUARIOS>---------------------------------
	
------------------------------------------------
--          CREACION DE LOGINS Y ROLS       ---
-----------------------------------------------

CREATE ROLE Supervisor
CREATE ROLE Impostor


CREATE LOGIN Richtofen
WITH PASSWORD = 'Elemento115!', DEFAULT_DATABASE = Com2900G07,
CHECK_POLICY = ON, CHECK_EXPIRATION = OFF ;
CREATE USER Richtofen FOR LOGIN Richtofen
go

CREATE LOGIN CapKrik
WITH PASSWORD = 'Enterprise1966', DEFAULT_DATABASE = Com2900G07,
CHECK_POLICY = ON, CHECK_EXPIRATION = OFF ;
CREATE USER CapKrik FOR LOGIN CapKrik
GO

--ROLS

GRANT EXECUTE, INSERT, DELETE, UPDATE ON SCHEMA::level2 TO Supervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON level2.notaCredito TO Supervisor;
GRANT EXECUTE ON level2.crearNotaCredito TO Supervisor;
go

REVOKE INSERT, UPDATE, DELETE ON level2.notaCredito TO PUBLIC;
REVOKE EXECUTE ON level2.crearNotaCredito TO PUBLIC
go


--Agrego los miembros al rol Supervisor
ALTER ROLE Supervisor ADD MEMBER Richtofen; 
go

-----------
--TEST----
----------


EXECUTE as LOGIN = 'Richtofen'
EXEC level2.crearNotaCredito '226-31-3083', 5, 2, 'Vinieron para uso de Daleks'
SELECT * FROM level2.notaCredito
GO

--Resultado esperado:
--  226-31-3083     5       2      'Vinieron para uso de Daleks'

EXECUTE AS LOGIN = 'CapKrik'
EXEC level2.crearNotaCredito '226-31-3083', 5, 2, 'Vinieron para uso de Daleks'
SELECT * FROM level2.notaCredito
GO
--Resultado esperado:
--No debería de pasar nada


REVERT      --volver a ser admin 
go


-----------------------<Creacion de la llave>-----------------------

--Creamos la llave simetrica que nos servira para encriptar
CREATE SYMMETRIC KEY keyEmpleado
WITH ALGORITHM = AES_256   --Algoritmo de encriptacion
ENCRYPTION BY PASSWORD = 'EmpleadoSecretos123!';
GO



---------------------------<SP DE ENCRIPTACION Y DESENCRIPTACION>-----------------------------------------------

CREATE OR ALTER PROCEDURE level2.encriptarEmpleados AS
BEGIN

    OPEN SYMMETRIC KEY KeyEmpleado
    DECRYPTION BY PASSWORD = 'EmpleadoSecretos123!';

    UPDATE level2.empleado
    SET 
        direccion = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), direccion),
        emailPersonal = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), emailPersonal)

    CLOSE SYMMETRIC KEY KeyEmpleado;
END
go

CREATE OR ALTER PROCEDURE level2.desencriptarEmpleados AS
BEGIN

    OPEN SYMMETRIC KEY KeyEmpleado
    DECRYPTION BY PASSWORD = 'EmpleadoSecretos123!';

    UPDATE level2.empleado
    SET 
    direccion = CONVERT(VARCHAR, DECRYPTBYKEY(direccion)),
    emailPersonal = CONVERT(VARCHAR, DECRYPTBYKEY(emailPersonal))

    CLOSE SYMMETRIC KEY KeyEmpleado;

END

-------------------------------------------<PRUEBAS>---------------------------------------

-->Encriptado:
EXEC level2.encriptarEmpleados
SELECT * FROM level2.empleado
go

-->Desencriptado:
EXEC level2.desencriptarEmpleados
SELECT * FROM level2.empleado
go
