----------INTODUCCION ------------------

--En este script estara el codigo para crear la base de datos con las tablas iniciales y el contenido inicial que no dio el cliente


create database Proyecto_Jano      
GO


create schema level1; --este nivel de esquema corresponde a la base de informacion del cual trabajara la base de datos
go 
--create schema level2; --este nivel de esquema corresponde a las tablas relacionadas a los reportes
--go 
---------CREAR TABLAS--------------

--A continuación se muestra el codigo para crear las tablas de nivel 1

create table level1.sucursal(id_sucursal int primary key identity(1,1),
							ciudad char(25) not null,
							sucursal char(25) not null,
							direccion char(50) not null)

create table level1.empleado(id int primary key,
							nombre char(25),
							apellido char(50),
							dni int unique not null,
							direccion char(100),
							emailEmpresa char(100),
							emailPersonal char(100),
							cargo char(25) not null,
							turno char(25) not null)


create table level1.productos(id_producto int primary key identity(1,1),	--1
								Categoria varchar (50) not null,				--electronicos
								NombreProd varchar (50) not null,				--macbook
								Precio decimal(10,2) not null,				--700
								ReferenciaPrecio decimal(10,2) not null,	--Cuanto pesa o cantidad(1)
								ReferenciaUnidad varchar(30) not null,			--(unidad) o cantidad que viene en el paquete
								FechaCarga datetime not null)
-- -----------------------------------------------------------------------------------------------------------------------
create table level1.VentaRegistrada(ID Factura char(50),
										Tipo de Factura char(1),
										Ciudad varchar(10),
										Tipo de cliente char(6),
										Genero varchar(6),
										Linea de producto varchar(50),
										Producto varchar(50),
										Precio Unitario decimal(10,2),
										Cantidad int,
										FechaHora datetime,
										Medio de Pago varchar(12),
										Empleado int,
										Sucursal varchar(20),
)
------------------- CREAR STOREDS PROCEDURES -------------------
-- A continuación se crea las tablas para la creación de los SP que se usaran para la manipulación de tablas

create procedure level1.insertarSucursal @ciudad char(25), @sucursal char(25), @direccion char(50) as

    BEGIN
    insert into level1.sucursal (ciudad, sucursal, direccion) 
    values (@ciudad, @sucursal, @direccion);
    END
go

create procedure level1.insertarEmpleado @id int, @nombre char(25), @apellido char(50), @dni int, @direccion char(100), @emailEmpresa char(100), @emailPersonal char(100), @cargo char(25), @turno char(25) as

    BEGIN
    insert into level1.empleado (id, nombre, apellido, dni, direccion, emailEmpresa, emailPersonal, cargo, turno) 
    values (@id, @nombre, @apellido, @dni, @direccion, @emailEmpresa, @emailPersonal, @cargo, @turno);
    END
go

create procedure level1.insertarProducto @producto char(50), @lineaProducto char(50) as

    BEGIN
    insert into level1.productos (producto, lineaProducto) 
    values (@producto, @lineaProducto);
    END
go


create procedure level1.insertarMedioPago @english char(25), @spanish char(25) as

    BEGIN
    insert into level1.medioPago (english, spanish) 
    values (@english, @spanish);
    END
go


----- INSERCION DE VALORES INICIALES-------------
--Se inicializara los valores que los clientes nos han dado 

exec level1.insertarSucursal 'Yangon', 'San Justo', 'Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires';
EXEC level1.insertarSucursal 'Naypyitaw', 'Ramos Mejia', 'Av. de Mayo 791, B1704 Ramos Mejía, Provincia de Buenos Aires';
EXEC level1.insertarSucursal 'Mandalay', 'Lomas del Mirador', ' Pres. Juan Domingo Perón 763, B1753AWO Villa Luzuriaga, Provincia de Buenos Aires';


EXEC level1.insertarEmpleado 257020, 'Romina Alejandra', 'ALIAS', 36383025, 'Bernardo de Irigoyen 2647, San Isidro, Buenos Aires', 'Romina Alejandra_ALIAS@gmail.com', 'Romina Alejandra.ALIAS@superA.com', 36383025, 'Cajero', 'Ramos Mejia', 'TM';
EXEC level1.insertarEmpleado 257021, 'Romina Soledad', 'RODRIGUEZ', 31816587, 'Av. Vergara 1910, Hurlingham, Buenos Aires', 'Romina Soledad_RODRIGUEZ@gmail.com', 'Romina Soledad.RODRIGUEZ@superA.com', 31816587, 'Cajero', 'Ramos Mejia', 'TT';
EXEC level1.insertarEmpleado 257022, 'Sergio Elio', 'RODRIGUEZ', 30103258, 'Av. Belgrano 422, Avellaneda, Buenos Aires', 'Sergio Elio_RODRIGUEZ@gmail.com', 'Sergio Elio.RODRIGUEZ@superA.com', 30103258, 'Cajero', 'Lomas del Mirador', 'TM';
EXEC level1.insertarEmpleado 257023, 'Christian Joel', 'ROJAS', 41408274, 'Calle 7 767, La Plata, Buenos Aires', 'Christian Joel_ROJAS@gmail.com', 'Christian Joel.ROJAS@superA.com', 41408274, 'Cajero', 'Lomas del Mirador', 'TT';
EXEC level1.insertarEmpleado 257024, 'María Roberta de los Angeles', 'ROLON GAMARRA', 30417854, 'Av. Arturo Illia 3770, Malvinas Argentinas, Buenos Aires', 'María Roberta de los Angeles_ROLON GAMARRA@gmail.com', 'María Roberta de los Angeles.ROLON GAMARRA@superA.com', 30417854, 'Cajero', 'San Justo', 'TM';
EXEC level1.insertarEmpleado 257025, 'Rolando', 'LOPEZ', 29943254, 'Av. Rivadavia 6538, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires', 'Rolando_LOPEZ@gmail.com', 'Rolando.LOPEZ@superA.com', 29943254, 'Cajero', 'San Justo', 'TT';
EXEC level1.insertarEmpleado 257026, 'Francisco Emmanuel', 'LUCENA', 37633159, 'Av. Don Bosco 2680, San Justo, Buenos Aires', 'Francisco Emmanuel_LUCENA@gmail.com', 'Francisco Emmanuel.LUCENA@superA.com', 37633159, 'Supervisor', 'Ramos Mejia', 'TM';
EXEC level1.insertarEmpleado 257027, 'Eduardo Matias', 'LUNA', 30338745, 'Av. Santa Fe 1954, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires', 'Eduardo Matias_LUNA@gmail.com', 'Eduardo Matias.LUNA@superA.com', 30338745, 'Supervisor', 'Lomas del Mirador', 'TM';
EXEC level1.insertarEmpleado 257028, 'Mauro Alberto', 'LUNA', 34605254, 'Av. San Martín 420, San Martín, Buenos Aires', 'Mauro Alberto_LUNA@gmail.com', 'Mauro Alberto.LUNA@superA.com', 34605254, 'Supervisor', 'San Justo', 'TM';
EXEC level1.insertarEmpleado 257029, 'Emilce', 'MAIDANA', 36508254, 'Independencia 3067, Carapachay, Buenos Aires', 'Emilce_MAIDANA@gmail.com', 'Emilce.MAIDANA@superA.com', 36508254, 'Supervisor', 'Ramos Mejia', 'TT';
EXEC level1.insertarEmpleado 257030, 'NOELIA GISELA FABIOLA', 'MAIDANA', 34636354, 'Bernardo de Irigoyen 2647, San Isidro, Buenos Aires', 'NOELIA GISELA FABIOLA_MAIDANA@gmail.com', 'NOELIA GISELA FABIOLA.MAIDANA@superA.com', 34636354, 'Supervisor', 'Lomas del Mirador', 'TT';
EXEC level1.insertarEmpleado 257031, 'Fernanda Gisela Evangelina', 'MAIZARES', 33127114, 'Av. Rivadavia 2243, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires', 'Fernanda Gisela Evangelina_MAIZARES@gmail.com', 'Fernanda Gisela Evangelina.MAIZARES@superA.com', 33127114, 'Supervisor', 'San Justo', 'TT';
EXEC level1.insertarEmpleado 257032, 'Oscar Martín', 'ORTIZ', 39231254, 'Juramento 2971, Ciudad Autónoma de Buenos Aires, Ciudad Autónoma de Buenos Aires', 'Oscar Martín_ORTIZ@gmail.com', 'Oscar Martín.ORTIZ@superA.com', 39231254, 'Gerente de sucursal', 'Ramos Mejia', 'Jornada completa';
EXEC level1.insertarEmpleado 257033, 'Débora', 'PACHTMAN', 30766254, 'Av. Presidente Hipólito Yrigoyen 299, Provincia de Buenos Aires, Provincia de Buenos Aires', 'Débora_PACHTMAN@gmail.com', 'Débora.PACHTMAN@superA.com', 30766254, 'Gerente de sucursal', 'Lomas del Mirador', 'Jornada completa';
EXEC level1.insertarEmpleado 257034, 'Romina Natalia', 'PADILLA', 38974125, 'Lacroze 5910, Chilavert, Buenos Aires', 'Romina Natalia_PADILLA@gmail.com', 'Romina Natalia.PADILLA@superA.com', 38974125, 'Gerente de sucursal', 'San Justo', 'Jornada completa';


/*ESTOS PRODUCTOS SON DEL ARCHIVO INFORMACION COMPLEMENTARIA, NO LO UTILIZAMOS
EXEC level1.insertarProducto 'aceite_vinagre_y_sal', 'Almacen';
EXEC level1.insertarProducto 'aceitunas_y_encurtidos', 'Almacen';
EXEC level1.insertarProducto 'acondicionador_y_mascarilla', 'Perfumeria';
EXEC level1.insertarProducto 'afeitado_y_cuidado_para_hombre', 'Perfumeria';
EXEC level1.insertarProducto 'agua', 'Almacen';
EXEC level1.insertarProducto 'alimentacion_infantil', 'Almacen';
EXEC level1.insertarProducto 'arreglos', 'Hogar';
EXEC level1.insertarProducto 'arroz', 'Almacen';
EXEC level1.insertarProducto 'arroz_y_pasta', 'Almacen';
EXEC level1.insertarProducto 'atun_y_otras_conservas_de_pescado', 'Almacen';
EXEC level1.insertarProducto 'aves_y_jamon_cocido', 'Frescos';
EXEC level1.insertarProducto 'aves_y_pollo', 'Frescos';
EXEC level1.insertarProducto 'azucar_y_edulcorante', 'Almacen';
EXEC level1.insertarProducto 'bacon_y_salchichas', 'Frescos';
EXEC level1.insertarProducto 'bases_de_maquillaje_y_corrector', 'Perfumeria';
EXEC level1.insertarProducto 'berberechos_y_mejillones', 'Almacen';
EXEC level1.insertarProducto 'biberon_chupete_y_menaje', 'Bazar';
EXEC level1.insertarProducto 'bifidus', 'Almacen';
EXEC level1.insertarProducto 'bolleria_de_horno', 'Almacen';
EXEC level1.insertarProducto 'bolleria_envasada', 'Almacen';
EXEC level1.insertarProducto 'cacao_soluble_y_chocolate_a_la_taza', 'Almacen';
EXEC level1.insertarProducto 'cafe_capsula_y_monodosis', 'Almacen';
EXEC level1.insertarProducto 'cafe_molido_y_en_grano', 'Almacen';
EXEC level1.insertarProducto 'cafe_soluble_y_otras_bebidas', 'Almacen';
EXEC level1.insertarProducto 'carne', 'Frescos';
EXEC level1.insertarProducto 'carne_congelada', 'Frescos';
EXEC level1.insertarProducto 'cerdo', 'Frescos';
EXEC level1.insertarProducto 'cereales', 'Almacen';
EXEC level1.insertarProducto 'cerveza', 'Bebidas';
EXEC level1.insertarProducto 'cerveza_sin_alcohol', 'Bebidas';
EXEC level1.insertarProducto 'champu', 'Perfumeria';
EXEC level1.insertarProducto 'chicles_y_caramelos', 'Almacen';
EXEC level1.insertarProducto 'chocolate', 'Almacen';
EXEC level1.insertarProducto 'chopped_y_mortadela', 'Frescos';
EXEC level1.insertarProducto 'coloracion_cabello', 'Perfumeria';
EXEC level1.insertarProducto 'colorete_y_polvos', 'Perfumeria';
EXEC level1.insertarProducto 'conejo_y_cordero', 'Frescos';
EXEC level1.insertarProducto 'conservas_de_verdura_y_frutas', 'Almacen';
EXEC level1.insertarProducto 'cuidado_corporal', 'Perfumeria';
EXEC level1.insertarProducto 'cuidado_e_higiene_facial', 'Perfumeria';
EXEC level1.insertarProducto 'depilacion', 'Perfumeria';
EXEC level1.insertarProducto 'desodorante', 'Perfumeria';
EXEC level1.insertarProducto 'detergente_y_suavizante_ropa', 'Limpieza';
EXEC level1.insertarProducto 'embutido', 'Almacen';
EXEC level1.insertarProducto 'embutido_curado', 'Almacen';
EXEC level1.insertarProducto 'empanados_y_elaborados', 'Frescos';
EXEC level1.insertarProducto 'especias', 'Almacen';
EXEC level1.insertarProducto 'estropajo_bayeta_y_guantes', 'Limpieza';
EXEC level1.insertarProducto 'fijacion_cabello', 'Perfumeria';
EXEC level1.insertarProducto 'fitoterapia', 'Otros';
EXEC level1.insertarProducto 'flan_y_natillas', 'Almacen';
EXEC level1.insertarProducto 'fruta', 'Frescos';
EXEC level1.insertarProducto 'fruta_variada', 'Frescos';
EXEC level1.insertarProducto 'frutos_secos_y_fruta_desecada', 'Almacen';
EXEC level1.insertarProducto 'galletas', 'Almacen';
EXEC level1.insertarProducto 'gato', 'Mascota';
EXEC level1.insertarProducto 'gazpacho_y_cremas', 'Almacen';
EXEC level1.insertarProducto 'gel_y_jabon_de_manos', 'Limpieza';
EXEC level1.insertarProducto 'gelatina_y_otros_postres', 'Almacen';
EXEC level1.insertarProducto 'golosinas', 'Almacen';
EXEC level1.insertarProducto 'hamburguesas_y_picadas', 'Frescos';
EXEC level1.insertarProducto 'harina_y_preparado_reposteria', 'Almacen';
EXEC level1.insertarProducto 'helados', 'Congelados';
EXEC level1.insertarProducto 'hielo', 'Congelados';
EXEC level1.insertarProducto 'higiene_bucal', 'Limpieza';
EXEC level1.insertarProducto 'higiene_intima', 'Limpieza';
EXEC level1.insertarProducto 'higiene_y_cuidado', 'Limpieza';
EXEC level1.insertarProducto 'huevos', 'Almacen';
EXEC level1.insertarProducto 'insecticida_y_ambientador', 'Limpieza';
EXEC level1.insertarProducto 'isotonico_y_energetico', 'Bebidas';
EXEC level1.insertarProducto 'jamon_serrano', 'Almacen';
EXEC level1.insertarProducto 'labios', 'Perfumeria';
EXEC level1.insertarProducto 'leche_y_bebidas_vegetales', 'Almacen';
EXEC level1.insertarProducto 'lechuga_y_ensalada_preparada', 'Frescos';
EXEC level1.insertarProducto 'legumbres', 'Almacen';
EXEC level1.insertarProducto 'lejia_y_liquidos_fuertes', 'Limpieza';
EXEC level1.insertarProducto 'licores', 'Bebidas';
EXEC level1.insertarProducto 'limpiacristales', 'Limpieza';
EXEC level1.insertarProducto 'limpiahogar_y_friegasuelos', 'Limpieza';
EXEC level1.insertarProducto 'limpieza_bano_y_wc', 'Limpieza';
EXEC level1.insertarProducto 'limpieza_cocina', 'Limpieza';
EXEC level1.insertarProducto 'limpieza_muebles_y_multiusos', 'Limpieza';
EXEC level1.insertarProducto 'limpieza_vajilla', 'Limpieza';
EXEC level1.insertarProducto 'manicura_y_pedicura', 'Perfumeria';
EXEC level1.insertarProducto 'mantequilla_y_margarina', 'Frescos';
EXEC level1.insertarProducto 'marisco', 'Frescos';
EXEC level1.insertarProducto 'mayonesa_ketchup_y_mostaza', 'Almacen';
EXEC level1.insertarProducto 'melocoton_y_pina', 'Frescos';
EXEC level1.insertarProducto 'menaje_y_conservacion_de_alimentos', 'Almacen';
EXEC level1.insertarProducto 'mermelada_y_miel', 'Almacen';
EXEC level1.insertarProducto 'naranja', 'Frescos';
EXEC level1.insertarProducto 'ojos', 'Otros';
EXEC level1.insertarProducto 'otras_salsas', 'Almacen';
EXEC level1.insertarProducto 'pan_de_horno', 'Almacen';
EXEC level1.insertarProducto 'pan_de_molde_y_otras_especialidades', 'Almacen';
EXEC level1.insertarProducto 'pan_tostado_y_rallado', 'Almacen';
EXEC level1.insertarProducto 'papel_higienico_y_celulosa', 'Limpieza';
EXEC level1.insertarProducto 'parafarmacia', 'Otros';
EXEC level1.insertarProducto 'pasta_y_fideos', 'Almacen';
EXEC level1.insertarProducto 'patatas_fritas_y_snacks', 'Almacen';
EXEC level1.insertarProducto 'pate_y_sobrasada', 'Almacen';
EXEC level1.insertarProducto 'peines_y_accesorios', 'Perfumeria';
EXEC level1.insertarProducto 'perfume_y_colonia', 'Perfumeria';
EXEC level1.insertarProducto 'perro', 'Mascota';
EXEC level1.insertarProducto 'pescado', 'Frescos';
EXEC level1.insertarProducto 'pescado_congelado', 'Frescos';
EXEC level1.insertarProducto 'pescado_en_bandeja', 'Frescos';
EXEC level1.insertarProducto 'pescado_fresco', 'Frescos';
EXEC level1.insertarProducto 'pez_y_otros', 'Frescos';
EXEC level1.insertarProducto 'picos_rosquilletas_y_picatostes', 'Almacen';
EXEC level1.insertarProducto 'pilas_y_bolsas_de_basura', 'Limpieza';
EXEC level1.insertarProducto 'pinceles_y_brochas', 'Hogar';
EXEC level1.insertarProducto 'pizzas', 'Almacen';
EXEC level1.insertarProducto 'platos_preparados_calientes', 'Comida';
EXEC level1.insertarProducto 'platos_preparados_frios', 'Comida';
EXEC level1.insertarProducto 'postres_de_soja', 'Almacen';
EXEC level1.insertarProducto 'protector_solar_y_aftersun', 'Perfumeria';
EXEC level1.insertarProducto 'queso_curado_semicurado_y_tierno', 'Almacen';
EXEC level1.insertarProducto 'queso_lonchas_rallado_y_en_porciones', 'Almacen';
EXEC level1.insertarProducto 'queso_untable_y_fresco', 'Almacen';
EXEC level1.insertarProducto 'refresco_de_cola', 'Bebidas';
EXEC level1.insertarProducto 'refresco_de_naranja_y_de_limon', 'Bebidas';
EXEC level1.insertarProducto 'refresco_de_te_y_sin_gas', 'Bebidas';
EXEC level1.insertarProducto 'salazones_y_ahumados', 'Almacen';
EXEC level1.insertarProducto 'sidra_y_cava', 'Bebidas';
EXEC level1.insertarProducto 'sopa_y_caldo', 'Almacen';
EXEC level1.insertarProducto 'tartas_y_churros', 'Almacen';
EXEC level1.insertarProducto 'tartas_y_pasteles', 'Almacen';
EXEC level1.insertarProducto 'te_e_infusiones', 'Almacen';
EXEC level1.insertarProducto 'tinto_de_verano_y_sangria', 'Bebidas';
EXEC level1.insertarProducto 'toallitas_y_panales', 'Perfumeria';
EXEC level1.insertarProducto 'tomate', 'Frescos';
EXEC level1.insertarProducto 'tomate_y_otros_sabores', 'Frescos';
EXEC level1.insertarProducto 'tonica_y_bitter', 'Bebidas';
EXEC level1.insertarProducto 'tortitas', 'Almacen';
EXEC level1.insertarProducto 'utensilios_de_limpieza_y_calzado', 'Limpieza';
EXEC level1.insertarProducto 'vacuno', 'Frescos';
EXEC level1.insertarProducto 'velas_y_decoracion', 'Hogar';
EXEC level1.insertarProducto 'verdura', 'Frescos';
EXEC level1.insertarProducto 'vino_blanco', 'Bebidas';
EXEC level1.insertarProducto 'vino_lambrusco_y_espumoso', 'Bebidas';
EXEC level1.insertarProducto 'vino_rosado', 'Bebidas';
EXEC level1.insertarProducto 'vino_tinto', 'Bebidas';
EXEC level1.insertarProducto 'yogures_desnatados', 'Almacen';
EXEC level1.insertarProducto 'yogures_griegos', 'Almacen';
EXEC level1.insertarProducto 'yogures_liquidos', 'Almacen';
EXEC level1.insertarProducto 'yogures_naturales_y_sabores', 'Almacen';
EXEC level1.insertarProducto 'yogures_y_postres_infantiles', 'Almacen';
*/


exec level1.insertarMedioPago 'Credit card', 'Tarjeta de credito'
exec level1.insertarMedioPago 'Cash', 'Efectivo'
exec level1.insertarMedioPago 'Ewallet', 'Billetera Electronica'




