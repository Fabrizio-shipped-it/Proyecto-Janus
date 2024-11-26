-------------------------------<CREACION DE TABLAS Y STORED PROCEDURES BASICOS>-----------------------------------------
/* 
fecha: 26/11/2024


===========================================<CONSIGNA>======================================================================

Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la sección de prácticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.

==========================================<Introduccion>===================================================================

-->En este script estara el codigo para crear la base de datos con las tablas iniciales y los sp basicos para hacer 
   funcionar el proyecto. Debe ejecutar los SP en orden con los que estan puestos. 


-->Cumplimiento de consigna: Entrega 3
-->Comision: 2900
-->Materia: Base de Datos Aplicada

-->Equipo 7: Proyecto Janus


	DNI			DIRECTORES DEL PROYECTO
 95054445  	MANGHI SCHECK, SANTIAGO
 44161995	ALTAMIRANO, FABRIZIO AUGUSTO
 44005719 	TORRES MORAN, MARIA CELESTE


=================================================<Indice>===================================================================

+TABLAS
+SP Sucursal
+SP Cargo
+SP Empleado
+SP Catalogo
+SP Productos
+SP MedioPago
+SP VentaRegistrada
+SP DetalleVenta
+SP NotaCredito

====================================================================================================================================================

*/
----------------------------------------------------------<Base de Datos>-------------------------------------------------------------------------

--drop database Com2900G07

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com2900G07')
BEGIN
    CREATE DATABASE Com2900G07;
END;
go
USE Com2900G07
go


-- Creamos los esquemas que ordenaran la Base de Datos.
-- Level 1 sera para Sucursal, Producto y Medio pago. 
-- Level 2 sera para Cargo, cliente, detalleVenta, empleado, factura y ventaRegistrada
-- Level 3 sera para notaCredito especificamente para la entrega 5

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'level1')
BEGIN
    EXEC('CREATE SCHEMA level1');
END
go
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'level2')
BEGIN
    EXEC('CREATE SCHEMA level2');
END
go
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'level3')
BEGIN
    EXEC('CREATE SCHEMA level3');
END
go

--------<====================================================<CREACION DE TABLAS>==========================================================>-------------------------------------------------


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'sucursal')
BEGIN
	CREATE TABLE level1.sucursal(	idSucursal INT PRIMARY KEY IDENTITY(1,1),
						ciudad VARCHAR(40),
						nombreSucursal VARCHAR (40) UNIQUE,
						direccion VARCHAR(100),
						telefono VARCHAR(10),
						cuit VARCHAR(13))
END					
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'cargo')
BEGIN

	CREATE TABLE level2.cargo(	idCargo INT PRIMARY KEY ,
						descripcionCargo VARCHAR (25) unique )
END
GO




IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'empleado')
BEGIN
CREATE TABLE level2.empleado(		legajo_Id INT PRIMARY KEY IDENTITY(257020,1),  
					nombre VARCHAR(50),
					apellido VARCHAR(50),
					dni INT,
					direccion VARCHAR(100),
					emailEmpresa VARCHAR(100),
					emailPersonal VARCHAR(100),
					cuil VARCHAR(13) DEFAULT '0',
					cargo VARCHAR(25) REFERENCES level2.cargo(descripcionCargo),			
					sucursal VARCHAR(40) REFERENCES level1.sucursal (nombreSucursal),		
					turno VARCHAR(4),
					estado char(10) CHECK (estado = '1' or estado = '0'))
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'producto')
BEGIN
	CREATE TABLE level1.producto(			idProducto INT PRIMARY KEY IDENTITY(1,1),	 	
							categoria VARCHAR(50) NOT NULL,	
							nombreProducto VARCHAR (100) NOT NULL,			
							precio DECIMAL(10,2) NOT NULL,
							referenciaUnidad VARCHAR(30),
							estado char(10) CHECK (estado = '1' or estado = '0'))			
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'cliente')
BEGIN
	CREATE TABLE level2.cliente(	idCliente INT PRIMARY KEY IDENTITY(1,1),	 	
							nombreComp VARCHAR(100) NOT NULL,			
							genero VARCHAR (100) NOT NULL,
							cuil VARCHAR(13),
							estado char(10) CHECK (estado = '1' or estado = '0'))			
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'medioPago')
BEGIN
	CREATE TABLE level1.medioPago(	idMedioPago INT PRIMARY KEY IDENTITY(1,1),	 	
								descripcion VARCHAR(20) NOT NULL)			
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ventaRegistrada')
BEGIN
	CREATE TABLE level2.ventaRegistrada(
						iD_Venta INT PRIMARY KEY IDENTITY(1,1),
						total_Bruto DECIMAL(10,2) default 0,
						total_IVA DECIMAL(10,2) default 0,
						empleado INT REFERENCES level2.empleado(legajo_Id),
						iD_MedioPago INT REFERENCES level1.medioPago(idMedioPago),
						identificadorPago VARCHAR(50)
)									
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'factura')
BEGIN
	CREATE TABLE level2.factura(
						iD_Factura VARCHAR(50) PRIMARY KEY,
						iD_Venta INT REFERENCES level2.ventaRegistrada(ID_Venta),
						iD_Sucursal INT REFERENCES level1.sucursal(idSucursal),
						tipoFactura CHAR(1),
						iD_Cliente INT REFERENCES level2.cliente(idCliente),
						fechaHora DATETIME,
						estado VARCHAR(20),
						cuit VARCHAR(13) 
)									
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'detalleVenta')
BEGIN
	CREATE TABLE level2.detalleVenta(				
						iDNroDetalle INT PRIMARY KEY IDENTITY(1,1),
						iD_Venta INT REFERENCES level2.ventaRegistrada(ID_Venta),
						idProducto INT REFERENCES level1.producto(idProducto),
						nombreProducto VARCHAR(100),
						referenciaUnidad VARCHAR(30),
						cantidad INT,
						precioUnitario DECIMAL(10,2)
)
END
GO


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'notaCredito')
BEGIN
	CREATE TABLE level3.notaCredito(				
						iDNota INT PRIMARY KEY IDENTITY(1,1),
						idFactura VARCHAR(50) REFERENCES level2.factura(iD_Factura),
						fecha DATETIME,
						monto DECIMAL(10,2),
						cantidad INT,
						codProd INT,
						motivoDev VARCHAR(200)
)
END
GO	



--------<====================================================<CREACION DE LOS SP>==========================================================>-------------------------------------------------


----------------------------------------------------------<SUCURSAL>--------------------------------------------------------------------------




CREATE OR ALTER PROCEDURE level1.insertarUnSucursal @ciudad VARCHAR(25), @nombreSucursal VARCHAR(40), @direccion VARCHAR(100), @telefono VARCHAR(10), @cuit VARCHAR(13) AS
BEGIN
    if (@ciudad IS NOT NULL and @ciudad != '' and @nombreSucursal IS NOT NULL and @nombreSucursal != '' and @direccion IS NOT NULL and @direccion != '' and @telefono IS NOT NULL and @telefono != '' )
	BEGIN
		--Si no existe una sucursal con mismo nombre.
		if((SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal=@nombreSucursal) IS NULL) 
		BEGIN
        INSERT INTO level1.sucursal (ciudad, nombreSucursal, direccion, telefono, cuit) 
        VALUES (@ciudad, @nombreSucursal, @direccion, @telefono, @cuit)
        PRINT ('Valores insertados correctamente en la tabla: Sucursal')
		END
		else
		print('Sucursal ya existente')
    END
    else
    BEGIN

        PRINT ('No se puede insertar a la tabla debido a que falta uno o más valores, o los valores superan el límite permitido.')

    END
END
GO



CREATE OR ALTER PROCEDURE level1.modificarSucursal  @idSucursal INT, @ciudad VARCHAR(25), @nombreSucursal VARCHAR(40), @direccion VARCHAR(100), @telefono VARCHAR(10), @cuit varchar(13) AS

	BEGIN
	-- Si existe sucursal del mismo nombre
	if (SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal = @nombreSucursal) IS NOT NULL
		BEGIN
	-- Si ningun campo es vacio
		if (@ciudad IS NOT NULL and @ciudad != '' and @nombreSucursal IS NOT NULL and @nombreSucursal != '' and @direccion IS NOT NULL and @direccion != '' and @telefono IS NOT NULL and @telefono != '' )
			BEGIN

			UPDATE level1.sucursal
			SET
			ciudad = @ciudad,
			nombreSucursal = @nombreSucursal,
			direccion = @direccion,
			telefono = @telefono,
            cuit = @cuit
			WHERE @idSucursal = idSucursal

			END
		else
			PRINT ('No se puede actualizar valores vacios.')

		END
	else
		PRINT ('No se ha encontrado la sucursal que se quiere modificar')

	END
GO


CREATE OR ALTER PROCEDURE level1.borrarSucursal @nombreSucursal VARCHAR(50) AS
BEGIN
	if (SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal = @nombreSucursal) IS NOT NULL	--si existe la sucursal que se quiere eliminar
	BEGIN
		DELETE FROM level2.empleado WHERE sucursal = @nombreSucursal
		DELETE FROM level1.sucursal WHERE nombreSucursal = @nombreSucursal
		PRINT ('La sucursal y sus empleados fueron eliminadados con exito.')

	END
	else
		print('No se ha encontrado la sucursal solicitada.')

END
GO

-----------------------------------------------------------------------<CARGO>---------------------------------------------------------------------

CREATE OR ALTER PROCEDURE level2.insertarCargo  @idCargo INT, @descripcionCargo VARCHAR(25) AS
BEGIN

	if (SELECT descripcionCargo FROM level2.Cargo WHERE descripcionCargo = @descripcionCargo) IS NULL and (SELECT idCargo FROM level2.cargo WHERE idCargo = @idCargo) IS NULL	
		BEGIN

		INSERT INTO level2.cargo (idCargo, descripcionCargo)
		VALUES (@idCargo, @descripcionCargo)
		print('Se ha creado el cargo correctamente')
		END
	
	else 
		print('Ya existe el cargo o el numero de id que quiere crear')

END
GO



CREATE OR ALTER PROCEDURE level2.borrarCargo @idCargo INT AS
BEGIN 
	if (SELECT idCargo FROM level2.cargo WHERE idCargo=@idCargo) IS NOT NULL
		BEGIN
		DELETE FROM level2.cargo WHERE idCargo = @idCargo
		print('Se ha eliminado el cargo correctamente')
		END
	else
		print('No existe el cargo que quiere eliminar')

END
GO

-------------------------------------------------------------------------<EMPLEADO>------------------------------------------------------------------


CREATE OR ALTER PROCEDURE level2.insertarUnEmpleado 
	@nombre VARCHAR(25), 
	@apellido VARCHAR(50), 
	@dni INT, 
	@direccion VARCHAR(100),
	@emailEmpresa VARCHAR(100), 
	@emailPersonal VARCHAR(100) , 
	@cuil VARCHAR(13), 
	@cargo VARCHAR(25), 
	@sucursal VARCHAR(40), 
	@turno VARCHAR(4) 
AS
BEGIN
    -- Valida que el DNI no esté repetido y esté dentro del rango
    IF (SELECT dni FROM level2.empleado WHERE dni = @dni) IS NULL 
        AND (@dni >= 10000000 AND @dni <= 99999999)
    BEGIN
        -- Valida que el cargo y la sucursal existan
        IF (SELECT descripcionCargo FROM level2.cargo WHERE descripcionCargo = @cargo) IS NOT NULL 
            AND (SELECT nombreSucursal FROM level1.sucursal WHERE nombreSucursal = @sucursal) IS NOT NULL
        BEGIN
            -- Inserta el nuevo empleado
            INSERT INTO level2.empleado 
                (nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cuil, cargo, sucursal, turno, estado) 
            VALUES 
                (@nombre, @apellido, @dni, @direccion, @emailEmpresa, @emailPersonal, @cuil, @cargo, @sucursal, @turno, '1');
            
            PRINT ('Valores insertados correctamente en la tabla: Empleado.');
        END
        ELSE
            PRINT('El valor de idSucursal y/o idCargo no existe');
    END
    ELSE
        PRINT('No se puede insertar el empleado a la tabla debido a que ya existe un empleado con ese DNI o el DNI tiene un valor incorrecto.');
END
GO



CREATE OR ALTER PROCEDURE level2.modificarEmpleado @legajo_Id INT, @nombre VARCHAR(25), @apellido VARCHAR(50), @direccion VARCHAR(100),
	    			@emailEmpresa VARCHAR(100), @emailPersonal VARCHAR(100) , @cuil VARCHAR(13), @idCargo VARCHAR(25), @idSucursal VARCHAR(50), @turno VARCHAR(4) AS
BEGIN

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NOT NULL
	BEGIN

		if(SELECT idCargo FROM level2.cargo WHERE descripcionCargo = @idCargo) IS NOT NULL AND (SELECT idSucursal FROM level1.sucursal WHERE nombreSucursal = @idSucursal) IS NOT NULL
		BEGIN
		UPDATE level2.empleado
		SET
		nombre = @nombre, 
		apellido = @apellido,
		direccion = @direccion, 
		emailEmpresa = @emailEmpresa, 
		emailPersonal = @emailPersonal, 
		cuil = @cuil,
		cargo = @idCargo,
		sucursal = @idSucursal,
		turno = @turno
		WHERE legajo_Id = @legajo_Id
		PRINT('Empleado actualizado.')
		END
		else
			print('Valor del idSucursal o idCargo no existe')

	END
	else
		PRINT('No se puede actualizar un empleado que no exista en la tabla.')
END
GO

--	Esta tabla tendra borrado logico. Asi que usaremos bajar empleado para indicar que esta inactivo, y reactivar para reactivar al empleado.

CREATE OR ALTER PROCEDURE level2.bajarEmpleado @legajo_Id INT AS
BEGIN

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NOT NULL
	BEGIN

		UPDATE
		level2.empleado
		SET
		estado = '0'
		WHERE legajo_Id = @legajo_Id
		print ('El empleado fue eliminado con exito.')
	END

	else
		print('No se ha encontrado al empleado.')

END
GO

CREATE OR ALTER PROCEDURE level2.reactivarEmpleado @legajo_Id INT AS
BEGIN

	if (SELECT legajo_Id FROM level2.empleado WHERE legajo_Id = @legajo_Id) IS NOT NULL
	BEGIN

		UPDATE
		level2.empleado
		SET
		estado = '1'
		WHERE legajo_Id = @legajo_Id
		print ('El empleado fue reactivado.')
	END

	else
		print('No se ha encontrado al empleado.')

END
GO

---------------------------------------------------------------------------------------<PRODUCTOS>----------------------------------------------------------------------------------------------


CREATE OR ALTER PROCEDURE level1.insertarUnProducto   @nombreProducto VARCHAR(100), @categoria VARCHAR(50), @precio DECIMAL(10,2), @referenciaUnidad VARCHAR(30) AS

    BEGIN
	--Verifico precio, que el producto con la misma unidad de referencia no exista
	if (@precio > 0) and (@nombreProducto IS NOT NULL and @nombreProducto != '' and (SELECT idProducto FROM level1.producto WHERE nombreProducto = @nombreProducto and referenciaUnidad = @referenciaUnidad) IS NULL)
 		BEGIN

		INSERT INTO level1.producto (nombreProducto, categoria, precio, referenciaUnidad, estado)
		VALUES (@nombreProducto, @categoria, @precio, @referenciaUnidad, 1)
		print ('Producto insertado exitosamente')
		END

	else
		print('No se puede insertar el producto dado que los datos a insertar son erroneos.')
    END
GO


CREATE OR ALTER PROCEDURE level1.modificarProducto @idProducto INT, @Categoria VARCHAR(40), @precio DECIMAL(10,2) AS
BEGIN
--Veridico que el nombre del producto exista
	if (SELECT idProducto FROM level1.producto WHERE idProducto = @idProducto) IS NOT NULL
		BEGIN
		--Verifico que el precio no sea menor a 0
		if (@precio > 0)
			BEGIN
			UPDATE level1.producto
			SET
			precio = @precio,
			Categoria = @Categoria
			WHERE idProducto = @idProducto
			print('Se ha actualizado el producto exitosamente')
			END
		else
			print('El precio no es aceptable')
		END
	else
		print('El producto a actualizar no se encuentra en la tabla')

END
GO

--Se usara borrado logico. Asi que se hace lo mismo que con empleados

CREATE OR ALTER PROCEDURE level1.bajarProducto @idProducto INT AS
BEGIN
    --Verifico que existe el producto
	if (SELECT idProducto FROM level1.producto WHERE idProducto = @idProducto) IS NOT NULL
	BEGIN

		UPDATE
		level1.producto
		SET
		estado = '0'
		WHERE idProducto = @idProducto
		print ('El producto fue dado de baja con exito.')
	END

	else
		print('No se ha encontrado el producto.')

END
GO

CREATE OR ALTER PROCEDURE level1.reactivarProducto @idProducto INT AS
BEGIN
    --Verifico que existe el producto
	if (SELECT idProducto FROM level1.producto WHERE idProducto = @idProducto) IS NOT NULL
	BEGIN

		UPDATE
		level1.producto
		SET
		estado = '1'
		WHERE idProducto = @idProducto
		print ('El producto fue reactivado con exito.')
	END

	else
		print('No se ha encontrado el producto.')

END
GO


------------------------------------------------------------------------------------<CLIENTES>--------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE level2.insertarCliente
    @nombreComp VARCHAR(100),
    @genero VARCHAR(100),
    @cuil VARCHAR(14)

BEGIN
        -- Insertar un nuevo cliente
        INSERT INTO level2.cliente (nombreComp, genero, cuil, estado)
        VALUES (@nombreComp, @genero, @cuil, '1'); -- CUIL vacío y estado activo

END;
GO

--Usaremos borrado logico

CREATE OR ALTER PROCEDURE level2.bajarCliente @idCliente INT AS
BEGIN
        --Verifico que existe el cliente
	IF (SELECT idCliente  FROM level2.cliente WHERE idCliente = @idCliente) IS NOT NULL
	BEGIN
		UPDATE level2.cliente
		SET estado = '0'
		WHERE idCliente = @idCliente
		print ('El cliente fue dado de baja con exito.')
	END

	ELSE
	BEGIN
		print('No se ha encontrado el cliente.')
	END

END;
GO

CREATE OR ALTER PROCEDURE level2.reactivarCliente @idCliente INT AS
BEGIN
    --Verifico que existe
	IF (SELECT idCliente  FROM level2.cliente WHERE idCliente = @idCliente) IS NOT NULL
	BEGIN
		UPDATE level2.cliente
		SET estado = '1'
		WHERE idCliente = @idCliente
		print ('El cliente fue reactivado con exito.')
	END

	else
		print('No se ha encontrado el cliente.')

END
GO

-------------------------------------------------------------------------------------------<VENTA REGISTRADA>------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE level2.insertarUnaVentaRegistrada 
    @tipoFactura CHAR(1),
    @idSucursal INT,
    @idCliente INT,
    @idEmpleado INT,
	@idFactura VARCHAR(50) AS
BEGIN
-- VALIDO SI LA SUCURSAL, EL EMPLEADO Y CLIENTE ESTAN REGISTRADOS Y QUE EL ID DE FACTURA NO ESTE DUPLICADO
	IF EXISTS (SELECT 1 FROM level1.sucursal WHERE idSucursal = @idSucursal)
	AND EXISTS (SELECT 1 FROM level2.empleado WHERE legajo_Id = @idEmpleado)
	AND (@tipoFactura = 'A'or @tipoFactura =  'B'or @tipoFactura =  'C')
	AND NOT EXISTS (SELECT 1 FROM level2.factura WHERE iD_Factura = @idFactura)
	BEGIN
--INSERTO
			--Declaro las variables
		DECLARE @idVenta INT;
		DECLARE @estado VARCHAR(20) = 'Emitida';
		DECLARE @cuit VARCHAR(13);
		DECLARE @fechaHora DATETIME = GETDATE();

			-- Obtener el CUIT de la sucursal
		SET @cuit = (SELECT cuit FROM level1.sucursal WHERE idSucursal = @idSucursal);

		IF EXISTS (SELECT 1 FROM level2.cliente WHERE idCliente = @idCliente AND estado = '1') OR @idCliente = 0
			BEGIN
					-- Insertar en la tabla VentaRegistrada
				INSERT INTO level2.ventaRegistrada (empleado, identificadorPago)
				VALUES (@idEmpleado, '-');

				SET @idVenta = SCOPE_IDENTITY(); --devuelve el valor IDENTITY insertado
				-- Insertar en la tabla factura
				INSERT INTO level2.factura (iD_Factura, iD_Venta, iD_Sucursal, tipoFactura, iD_Cliente, fechaHora, estado, cuit)
				VALUES (@idFactura, @idVenta, @idSucursal, @tipoFactura, @idCliente, @fechaHora, @estado, @cuit);

				PRINT 'Venta y factura registradas exitosamente';
			END
		ELSE
            BEGIN
                 PRINT 'Error: Cliente no existe o está desactivado.';
                 RETURN;
			END
	END
    ELSE
    BEGIN
        -- Imprimir el mensaje de error acumulado
        PRINT 'Error: Alguna de las validaciones falló. No se pudo insertar la venta. Revise si los datos son correctos';
    END
END;
GO

--------------------------------------------------------------------------------------<DETALLE VENTA>-----------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE level2.InsertarDetalleVenta @idFactura VARCHAR(50), @idProducto INT, @cantidad INT  AS
BEGIN
	-- Verificar si el idFactura existe y que este en estado activo el producto
	IF ( EXISTS(SELECT 1 FROM level2.factura WHERE iD_Factura = @idFactura)
	AND EXISTS (SELECT 1 FROM level1.producto WHERE idProducto = @idProducto AND estado = '1')
	AND  @cantidad > 0)
	BEGIN


		if((SELECT estado FROM level2.factura WHERE iD_Factura= @idFactura) = 'Emitida')
		BEGIN
			DECLARE @total DECIMAL(10, 2) =0;

			-- Obtener el Nombre del producto
			DECLARE @nombreProducto VARCHAR (100) = (SELECT nombreProducto  FROM level1.producto WHERE idProducto = @idProducto)
		-- Obtener el precio unitario del producto
			DECLARE @precioUnitario DECIMAL (10,2) = (SELECT precio FROM level1.producto WHERE idProducto = @idProducto)
		-- Obtener el IdVenta
			DECLARE @iD_Venta INT= (SELECT iD_Venta FROM level2.factura WHERE iD_Factura = @idFactura)
		
		
		-- Insertar en la tabla detalleVenta
			INSERT INTO level2.detalleVenta (iD_Venta,idProducto, nombreProducto, cantidad, precioUnitario)
			VALUES (@iD_Venta, @idProducto, @nombreProducto, @cantidad, @precioUnitario);

		-- Calcular el nuevo total de la factura sumando todos los productos
			SET @total = @cantidad * @precioUnitario;

        -- Actualizar los totales en ventaRegistrada
       	 UPDATE level2.ventaRegistrada
       	 SET total_Bruto = total_Bruto + @total,
        	total_IVA = total_IVA + (@total * 1.21)
        	WHERE iD_Venta = @iD_Venta;
				PRINT 'Detalle de venta insertado y totales actualizados correctamente.';
		END
		else
			print('La factura ya esta cerrada')
	END
	ELSE 
	BEGIN
		PRINT 'Error: La factura no existe o el producto no está activo.';
	END
END;
go

CREATE OR ALTER PROCEDURE level2.eliminarDetalleVenta @iD_Venta VARCHAR(50) AS
BEGIN

	DELETE FROM level2.detalleVenta WHERE iD_Venta = @iD_Venta
	 UPDATE level2.ventaRegistrada
	 SET total_Bruto = 0,
         total_IVA = 0
     WHERE iD_Venta = @iD_Venta;
END
go
-----------------------------------------------------------------------------------------<MEDIO DE PAGO>---------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE level1.insertarMedioPago
    @descripcion VARCHAR(20) AS
BEGIN
    IF EXISTS (SELECT 1 FROM level1.medioPago WHERE descripcion = @descripcion)
    BEGIN
        PRINT 'Error: El medio de pago ya existe.';
        RETURN;
    END
    
    INSERT INTO level1.medioPago (descripcion)
    VALUES (@descripcion);

    PRINT 'Medio de pago insertado exitosamente.';
END;
GO

	
	
CREATE OR ALTER PROCEDURE level1.borrarMedioPago
    @idMedioPago INT AS
BEGIN
    IF EXISTS (SELECT 1 FROM level1.medioPago WHERE idMedioPago = @idMedioPago)
    BEGIN
        DELETE FROM level1.medioPago
        WHERE idMedioPago = @idMedioPago;

        PRINT 'Medio de pago eliminado exitosamente.';
    END
    ELSE
    BEGIN
        PRINT 'Error: El medio de pago no existe.';
    END
END;
GO

CREATE OR ALTER PROCEDURE level1.modificarMedioPago
    @idMedioPago INT,
    @nuevaDescripcion VARCHAR(20) AS
BEGIN
    IF EXISTS (SELECT 1 FROM level1.medioPago WHERE idMedioPago = @idMedioPago)
    BEGIN
        IF EXISTS (SELECT 1 FROM level1.medioPago WHERE descripcion = @nuevaDescripcion)
        BEGIN
            PRINT 'Error: Ya existe un medio de pago con esa descripción.';
            RETURN;
        END

        UPDATE level1.medioPago
        SET descripcion = @nuevaDescripcion
        WHERE idMedioPago = @idMedioPago;

        PRINT 'Medio de pago actualizado exitosamente.';
    END
    ELSE
    BEGIN
        PRINT 'Error: El medio de pago no existe.';
    END
END;
GO
----------------------------------------------------------------------------------<CAMBIAR EL ESTADO DE FACTURA>------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE level2.registroPagoFactura 
    @idFactura VARCHAR(50),
    @iD_MedioPago INT,
    @identificadorPago VARCHAR(50) AS
BEGIN
    -- Verificar si la factura existe
    IF EXISTS (SELECT 1 FROM level2.factura WHERE iD_Factura = @idFactura AND estado='Emitida')
    BEGIN
        -- Declarar variables
        DECLARE @iD_Venta INT;
        DECLARE @estado VARCHAR(20);

        -- Obtener el ID de la venta asociada
        SET @iD_Venta = (SELECT iD_Venta FROM level2.factura WHERE iD_Factura = @idFactura);

        -- Si el iD_MedioPago es 0, cancelar la factura
        IF @iD_MedioPago = 0
        BEGIN
            -- Actualizar el estado de la factura a 'Cancelada'
            UPDATE level2.factura
            SET estado = 'Cancelada'
            WHERE iD_Factura = @idFactura;

            -- Actualizar el identificador y medio de pago en la venta
            UPDATE level2.ventaRegistrada
            SET iD_MedioPago = 0, identificadorPago = '-'
            WHERE iD_Venta = @iD_Venta;

            PRINT 'La factura ha sido cancelada exitosamente.';
        END
        ELSE
        BEGIN
            -- Verificar si el iD_MedioPago existe en la tabla medioPago
            IF EXISTS (SELECT 1 FROM level1.medioPago WHERE idMedioPago = @iD_MedioPago)
            BEGIN
                -- Actualizar el estado de la factura a 'Pagada'
                UPDATE level2.factura
                SET estado = 'Pagada'
                WHERE iD_Factura = @idFactura;

                -- Actualizar el identificador y medio de pago en la venta
                UPDATE level2.ventaRegistrada
                SET iD_MedioPago = @iD_MedioPago, identificadorPago = @identificadorPago
                WHERE iD_Venta = @iD_Venta;

                PRINT 'La factura ha sido pagada exitosamente.';
            END
            ELSE
            BEGIN
                PRINT 'Error: El medio de pago especificado no existe.';
            END
        END
    END
    ELSE
    BEGIN
        PRINT 'Error: La factura especificada no existe.';
    END
END;
GO


-----------------------------------------------------------------------------------------------<Nota Credito>-------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE level3.crearNotaCredito @idFactura VARCHAR(50), @codProd INT, @cantidad INT, @motivoDev VARCHAR(50) AS
BEGIN

	if((SELECT iD_Factura FROM level2.factura WHERE iD_Factura = @idFactura) IS NOT NULL) 			--Verifico si la venta existe
	BEGIN

	DECLARE @idVenta INT = (SELECT iD_Venta FROM level2.factura WHERE iD_Factura = @idFactura)	--OBTENGO EL ID VENTA DE FACTURA
		IF( (SELECT 1 FROM level2.detalleVenta WHERE idProducto = @codProd AND iD_Venta = @idVenta) IS NOT NULL) 	--VERIFICO QUE EXISTIO LA VENTA DEL PRODUCTO
			BEGIN
			--Verifico que la cantidad sea mayor a 0 y menor a los comprado y lo devuelto
			DECLARE @cantidadComprada INT =  (SELECT cantidad FROM level2.detalleVenta WHERE iD_Venta = @idVenta AND idProducto = @codProd)
			DECLARE @cantidadDevuelta INT = ISNULL(( SELECT sum(cantidad) FROM level3.notaCredito WHERE idFactura = @idFactura), 0)
			
			if(@cantidad>0 and @cantidad<= @cantidadComprada - @cantidadDevuelta)	
			BEGIN
			DECLARE @precioUnitario INT = (SELECT precio FROM level1.producto WHERE idProducto = @codProd)
			DECLARE @fecha DATETIME = GETDATE()
			INSERT INTO level3.notaCredito (idFactura, fecha, monto, cantidad, codProd, motivoDev)
			VALUES (@idFactura, @fecha, @precioUnitario*@cantidad, @cantidad, @codProd, @motivoDev)
			END

			else
				print('la cantidad supera a la comprada');
		END
		else
			print('No se ha comprado ese producto');
	END
	else
		print('No se ha encontrado la factura')

END
go

CREATE OR ALTER PROCEDURE level3.sacarNotaCredito @idNotaCredito INT AS
BEGIN

	IF (SELECT iDNota FROM level3.notaCredito WHERE iDNota = @idNotaCredito) IS NOT NULL
	BEGIN
	DELETE level3.notaCredito WHERE iDNota = @idNotaCredito
	print('Nota de credito sacada con exito')
	END
	else
		print('No existe la nota de credito')
END

--------------------------------------------------------------------------------------------------<Generativo de ventas>

CREATE OR ALTER PROCEDURE level2.insertarVentasConDetallesAleatorios
    @cantidadVentas INT,              -- Cantidad de ventas que quieres generar
    @cantidadDetallesPorVenta INT     -- Cantidad de detalles (productos) por cada venta
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @j INT;                    -- Para el bucle interno de detalles
    DECLARE @idSucursal INT = (SELECT TOP 1 idSucursal FROM level1.sucursal ORDER BY NEWID());  -- Sucursal aleatoria
    DECLARE @idEmpleado INT = (SELECT TOP 1 legajo_Id FROM level2.empleado ORDER BY NEWID());    -- Empleado aleatorio
    DECLARE @idCliente INT = (SELECT TOP 1 idCliente FROM level2.cliente WHERE estado = '1' ORDER BY NEWID()); -- Cliente activo aleatorio
    DECLARE @tipoFactura CHAR(1) = 
									CASE 
										WHEN RAND() < 0.33 THEN 'A'  -- 33% de probabilidad para 'A'
										WHEN RAND() < 0.66 THEN 'B'  -- 33% de probabilidad para 'B'
										ELSE 'C'                     -- 34% de probabilidad para 'C'
									END;
    DECLARE @idFactura VARCHAR(50);
	
    -- Bucle para insertar las ventas
    WHILE @i <= @cantidadVentas
    BEGIN
        -- Generar un ID de factura único
        SET @idFactura = 'FAC' + CAST(NEWID() AS VARCHAR(50));

        --insertarUnaVenta le mando tipo de factura, id sucursal, id cliente, id empleado, id factura

        EXEC level2.insertarUnaVentaRegistrada 
            @tipoFactura = @tipoFactura,
            @idSucursal = @idSucursal,
            @idCliente = @idCliente,
            @idEmpleado = @idEmpleado,
            @idFactura = @idFactura;

        -- Bucle para insertar los detalles de la venta
        SET @j = 1;
        WHILE @j <= @cantidadDetallesPorVenta
        BEGIN
            -- Generar un producto aleatorio
            DECLARE @idProducto INT = (SELECT TOP 1 idProducto FROM level1.producto WHERE estado = '1' ORDER BY NEWID());
            DECLARE @cantidad INT = FLOOR(RAND() * 10) + 1;  -- Generar una cantidad aleatoria entre 1 y 10

				--insertar un detalle le mando id factura, id producto, cantidad	

            EXEC level2.InsertarDetalleVenta 
                @idFactura = @idFactura,
                @idProducto = @idProducto,
                @cantidad = @cantidad;

            SET @j = @j + 1;  -- Incrementar el contador de detalles
        END
		SET @idEmpleado = (SELECT TOP 1 legajo_Id FROM level2.empleado ORDER BY NEWID());
		SET @idCliente = (SELECT TOP 1 idCliente FROM level2.cliente WHERE estado = '1' ORDER BY NEWID());
		SET @idSucursal = (SELECT TOP 1 idSucursal FROM level1.sucursal ORDER BY NEWID());
        SET @i = @i + 1;  -- Incrementar el contador de ventas
    END

    PRINT 'Ventas y detalles generados exitosamente.';
END
GO

/*
EXEC level2.insertarVentasConDetallesAleatorios @cantidadVentas = 10, @cantidadDetallesPorVenta = 3;
GO
--registrar pago le envio id factura, id medio de pago, identificador
--select * from level2.factura
EXEC level2.registroPagoFactura @idFactura = 'Completar con valor de tabla factura',
								 @iD_MedioPago = 0,
								 @identificadorPago = 'TX567';

EXEC level2.registroPagoFactura @idFactura = 'Completar con valor de tabla factura',
								 @iD_MedioPago = 1,
								 @identificadorPago = 'TX567';

EXEC level2.registroPagoFactura @idFactura = 'Completar con valor de tabla factura',
								 @iD_MedioPago = 2,
								 @identificadorPago = 'TX567';

EXEC level2.registroPagoFactura @idFactura = 'Completar con valor de tabla factura',
								 @iD_MedioPago = 3,
								 @identificadorPago = 'TX567';


select * from level1.producto
select * from level1.sucursal
select * from level1.medioPago

select * from level2.cargo
select * from level2.empleado
select * from level2.cliente

select * from level2.ventaRegistrada
delete from level2.ventaRegistrada

select * from level2.factura
delete from level2.factura

select * from level2.detalleVenta
delete from level2.detalleVenta

*/
