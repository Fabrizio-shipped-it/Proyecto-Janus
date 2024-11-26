-------------------------------<Encriptacion y Seguridad>-----------------------------------------

/* 
fecha de entrega: 26/11/2024




Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.
La información de las ventas es de vital importancia para el negocio, por ello se requiere que
se establezcan políticas de respaldo tanto en las ventas diarias generadas como en los
reportes generados.
Plantee una política de respaldo adecuada para cumplir con este requisito y justifique la
misma.


------------------------------------<Introduccion>------------------------------------

-->En este script estara a su disposición la creación de los roles y privilegios, y de la encriptación de tabla empleado. Se recomienda ejecutar por partes.


-->Cumplimiento de consigna: Entrega 5
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7: Proyecto Janus


	DNI			DIRECTORES DEL PROYECTO
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE


---------[Indice]--------------
+   Creacion de Roles y permisos
+   Creacion de la llave
+   SP de encriptado y desencriptado
+   Pruebas de Encriptacion

--------------------------------


*/

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com2900G07')
BEGIN
    print('Debe ejecutar el script de creacion de tablas y sq para poder usar este script')
END;


USE Com2900G07
GO

--Primero tenemos que crear la columna que identificara cuando una fila esta encriptada y cuando no.
--Por cuestiones de consigna, se ha decidido alterar la tabla en este script. 
--Para eso ejecute el siguiente codigo:

--EJECUTAR SOLO UNA VEZ


CREATE OR ALTER PROCEDURE level2.agregarcolumnaEncriptado AS
BEGIN
ALTER TABLE level2.empleado ADD encriptado INT DEFAULT 0
END
go
	
CREATE OR ALTER PROCEDURE level2.prepararEncriptado AS
BEGIN      
	UPDATE level2.empleado
	 SET encriptado = 0
END
go
 
EXEC level2.agregarcolumnaEncriptado
go
EXEC level2.prepararEncriptado
go



--Hasta aca se ha preparado la tabla para la encriptacion. Si desea correr todo de una, recuerde comentar
--EXEC level2.agregarcolumnaEncriptado para evitar errores

-----------------------<CREACION DE ROLES Y USUARIOS>---------------------------------
	
------------------------------------------------
--          CREACION DE ROLS       ---
-----------------------------------------------


IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Supervisor' AND type = 'R' )
BEGIN
    CREATE ROLE Supervisor
END
go

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Cajero' AND type = 'R')
BEGIN
    CREATE ROLE Cajero
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'GerenteDeSucursal' AND type = 'R')
BEGIN
    CREATE ROLE GerenteDeSucursal
END
GO


--PARA SUPERVISOR
--El supervisor tendra acceso a la tabla NotaCredito como el cliente deseo.


GRANT EXECUTE, INSERT, DELETE, UPDATE ON SCHEMA::level3 TO Supervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON level3.notaCredito TO Supervisor;
GRANT EXECUTE ON level3.crearNotaCredito TO Supervisor;
go


--PARA CAJERO
--El cajero tendra acceso a la tabla ventaRegistrada, factura, cliente y detalleVenta

GRANT EXECUTE, INSERT, UPDATE ON SCHEMA::level2 TO Cajero
GRANT SELECT, INSERT, UPDATE ON level2.ventaRegistrada TO Cajero
GRANT SELECT, INSERT, UPDATE ON level2.factura TO Cajero
GRANT SELECT, INSERT, UPDATE ON level2.detalleVenta TO Cajero
GRANT SELECT, INSERT, UPDATE, DELETE ON level2.cliente TO Cajero
GRANT EXECUTE ON level2.insertarCliente TO Cajero
GRANT EXECUTE ON level2.bajarCliente TO Cajero
GRANT EXECUTE ON level2.reactivarCliente TO Cajero
GRANT EXECUTE ON level2.insertarCliente TO Cajero
GRANT EXECUTE ON level2.insertarUnaVentaRegistrada TO Cajero
GRANT EXECUTE ON level2.InsertarDetalleVenta TO Cajero
GRANT EXECUTE ON level2.registroPagoFactura TO Cajero

--PARA GERENTE DE SUCURSAL
--El gerente de Sucursal tendra acceso a la tabla Sucursal, Empleado, Producto, MedioPago y Cargo

GRANT EXECUTE, INSERT, UPDATE ON SCHEMA::level1 TO GerenteDeSucursal
GRANT EXECUTE, INSERT, UPDATE ON SCHEMA::level2 TO GerenteDeSucursal
GRANT SELECT, INSERT, UPDATE, DELETE ON level1.producto TO GerenteDeSucursal
GRANT SELECT, INSERT, UPDATE, DELETE ON level2.empleado TO GerenteDeSucursal
GRANT SELECT, INSERT, UPDATE, DELETE ON level1.medioPago TO GerenteDeSucursal
GRANT SELECT, INSERT, UPDATE, DELETE ON level1.sucursal TO GerenteDeSucursal
GRANT SELECT, INSERT, UPDATE, DELETE ON level2.cargo TO GerenteDeSucursal

GRANT EXECUTE ON level1.insertarUnSucursal TO GerenteDeSucursal
GRANT EXECUTE ON level1.modificarSucursal TO GerenteDeSucursal
GRANT EXECUTE ON level1.borrarSucursal TO GerenteDeSucursal

GRANT EXECUTE ON level2.insertarCargo TO GerenteDeSucursal
GRANT EXECUTE ON level2.borrarCargo TO GerenteDeSucursal

GRANT EXECUTE ON level1.insertarMedioPago TO GerenteDeSucursal
GRANT EXECUTE ON level1.borrarMedioPago TO GerenteDeSucursal

GRANT EXECUTE ON level2.insertarUnEmpleado TO GerenteDeSucursal
GRANT EXECUTE ON level2.modificarEmpleado TO GerenteDeSucursal
GRANT EXECUTE ON level2.bajarEmpleado TO GerenteDeSucursal
GRANT EXECUTE ON level2.reactivarEmpleado TO GerenteDeSucursal

GRANT EXECUTE ON level1.insertarUnProducto TO GerenteDeSucursal
GRANT EXECUTE ON level1.modificarProducto TO GerenteDeSucursal
GRANT EXECUTE ON level1.bajarProducto TO GerenteDeSucursal
GRANT EXECUTE ON level1.reactivarProducto TO GerenteDeSucursal



--Ahora sacamos el acceso de todo a toda cuenta que no pertenezca al rol

REVOKE EXECUTE, INSERT, UPDATE, DELETE ON SCHEMA::level1 FROM PUBLIC
REVOKE EXECUTE, INSERT, UPDATE, DELETE ON SCHEMA::level2 FROM PUBLIC
REVOKE EXECUTE, INSERT, UPDATE, DELETE ON SCHEMA::level3 FROM PUBLIC

REVOKE EXECUTE ON level3.crearNotaCredito FROM PUBLIC

REVOKE SELECT, INSERT, UPDATE, DELETE ON level2.ventaRegistrada FROM PUBLIC
REVOKE SELECT, INSERT, UPDATE, DELETE ON level2.factura FROM PUBLIC
REVOKE SELECT, INSERT, UPDATE, DELETE ON level2.detalleVenta FROM PUBLIC
REVOKE SELECT, INSERT, UPDATE, DELETE ON level2.cliente FROM PUBLIC

REVOKE EXECUTE ON level2.insertarCliente FROM PUBLIC
REVOKE EXECUTE ON level2.bajarCliente FROM PUBLIC
REVOKE EXECUTE ON level2.reactivarCliente FROM PUBLIC
REVOKE EXECUTE ON level2.insertarUnaVentaRegistrada FROM PUBLIC
REVOKE EXECUTE ON level2.InsertarDetalleVenta FROM PUBLIC
REVOKE EXECUTE ON level2.registroPagoFactura FROM PUBLIC

REVOKE SELECT, INSERT, UPDATE, DELETE ON level1.producto FROM PUBLIC
REVOKE SELECT, INSERT, UPDATE, DELETE ON level2.empleado FROM PUBLIC
REVOKE SELECT, INSERT, UPDATE, DELETE ON level1.medioPago FROM PUBLIC
REVOKE SELECT, INSERT, UPDATE, DELETE ON level1.sucursal FROM PUBLIC
REVOKE SELECT, INSERT, UPDATE, DELETE ON level2.cargo FROM PUBLIC

REVOKE EXECUTE ON level1.insertarUnSucursal FROM PUBLIC
REVOKE EXECUTE ON level1.modificarSucursal FROM PUBLIC
REVOKE EXECUTE ON level1.borrarSucursal FROM PUBLIC

REVOKE EXECUTE ON level2.insertarCargo FROM PUBLIC
REVOKE EXECUTE ON level2.borrarCargo FROM PUBLIC

REVOKE EXECUTE ON level1.insertarMedioPago FROM PUBLIC
REVOKE EXECUTE ON level1.borrarMedioPago FROM PUBLIC

REVOKE EXECUTE ON level2.insertarUnEmpleado FROM PUBLIC
REVOKE EXECUTE ON level2.modificarEmpleado FROM PUBLIC
REVOKE EXECUTE ON level2.bajarEmpleado FROM PUBLIC
REVOKE EXECUTE ON level2.reactivarEmpleado FROM PUBLIC

REVOKE EXECUTE ON level1.insertarUnProducto FROM PUBLIC
REVOKE EXECUTE ON level1.modificarProducto FROM PUBLIC
REVOKE EXECUTE ON level1.bajarProducto FROM PUBLIC
REVOKE EXECUTE ON level1.reactivarProducto FROM PUBLIC
GO


-- Ya esta listo todo. Para ver como asignar roles y ejecutarlos, ver Lote de Pruebas II


-----===================================================<ENCRIPTACION>=================================================================--------------

-----------------------<Creacion de la llave>-------------------------------------

--Creamos la llave simetrica que nos servira para encriptar
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = 'keyEmpleado')
BEGIN
    CREATE SYMMETRIC KEY keyEmpleado
    WITH ALGORITHM = AES_256 -- Algoritmo de encriptación
    ENCRYPTION BY PASSWORD = 'EmpleadoSecretos123!';
END;
GO




---------------------------<SP DE ENCRIPTACION Y DESENCRIPTACION>-----------------------------------------------

CREATE OR ALTER PROCEDURE level2.encriptarEmpleados AS
BEGIN

    OPEN SYMMETRIC KEY KeyEmpleado
    DECRYPTION BY PASSWORD = 'EmpleadoSecretos123!';
            ALTER TABLE level2.empleado ALTER COLUMN dni NVARCHAR(256)
            ALTER TABLE level2.empleado ALTER COLUMN direccion NVARCHAR(256)
            ALTER TABLE level2.empleado ALTER COLUMN emailPersonal NVARCHAR(256)
            ALTER TABLE level2.empleado ALTER COLUMN nombre NVARCHAR(256)
            ALTER TABLE level2.empleado ALTER COLUMN apellido NVARCHAR(256)
    UPDATE level2.empleado
    SET 
        direccion = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), direccion),
        emailPersonal = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), emailPersonal),
		nombre = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), nombre),
        apellido = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), apellido),
		dni = ENCRYPTBYKEY(KEY_GUID('KeyEmpleado'), CONVERT(nvarchar(256), dni)),

		encriptado = 1
		WHERE encriptado = 0 or encriptado = null


    CLOSE SYMMETRIC KEY KeyEmpleado;
END
go

CREATE OR ALTER PROCEDURE level2.desencriptarEmpleados AS
BEGIN

    OPEN SYMMETRIC KEY KeyEmpleado
    DECRYPTION BY PASSWORD = 'EmpleadoSecretos123!';
            ALTER TABLE level2.empleado ALTER COLUMN dni NVARCHAR(256)
            ALTER TABLE level2.empleado ALTER COLUMN direccion NVARCHAR(256)
            ALTER TABLE level2.empleado ALTER COLUMN emailPersonal NVARCHAR(256)
            ALTER TABLE level2.empleado ALTER COLUMN nombre NVARCHAR(256)
            ALTER TABLE level2.empleado ALTER COLUMN apellido NVARCHAR(256)


		UPDATE level2.empleado
		SET 
		direccion = CONVERT(nVARCHAR(256), DECRYPTBYKEY(direccion)),
		emailPersonal = CONVERT(nVARCHAR(256), DECRYPTBYKEY(emailPersonal)),
		nombre = CONVERT(nVARCHAR(256), DECRYPTBYKEY(nombre)),
		apellido = CONVERT(nVARCHAR(256), DECRYPTBYKEY(apellido)),
		dni = CONVERT(nVARCHAR(256), DECRYPTBYKEY(CONVERT(nvarchar(256), dni))),
		encriptado = 0
		WHERE encriptado = 1




    CLOSE SYMMETRIC KEY KeyEmpleado;

END
go


