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

+   Creacion de la llave
+   SP de encriptado y desencriptado
+   Pruebas

--------------------------------


*/

USE Com2900G07
GO

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
