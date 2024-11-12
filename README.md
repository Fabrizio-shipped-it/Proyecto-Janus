# Proyecto Janus

## Introducción

**Proyecto Janus** es un trabajo práctico de *Base de Datos Aplicada* cuyo objetivo es gestionar datos de productos y ventas de diferentes sucursales. A partir de una base de datos, el proyecto permite descargar productos desde archivos y registrar ventas realizadas en varias sucursales.

---

## Instrucciones de Instalación y Uso

El repositorio esta ordenado de tal forma que los scripts estan enumerado por orden de ejecución

1. **Ejecución del Creador de Tablas y Procedimientos Almacenados**
   - Primero, ejecute el script `CreadorDeTablasYSP`. Esto creará todas las tablas y SP necesarios para el correcto funcionamiento del proyecto. A su vez, esta disponible el Lote de Pruebas I para que pueda probar el correcto funcionamiento de estos.

2. **Ejecución del Creador de Tablas y Procedimientos Ventas**
   - Una vez ejecutado el primer script, podra ejecutar el scripr `CreadorDeTablasYSPVentas` del cual expande la Base de Datos a tablas que almacenaran las ventas teniendo en cuenta los datos existentes en el Proyecto. A su disposición cuenta con el Lote de Pruebas II del cual le servira para poder probar los SP de este Script.

3. **Ejecución de Importación**
   - Este archivo contiene el script para importar los archivos xlsx y csv.

4. **Ejecución de Reportes**
   - Este archivo contiene el script para poder realizar reportes a partir de los datos almacenados.

5. **Ejecución del Archivo de Seguridad**
   - Finalmente, ejecuta el archivo de seguridad para implementar la encriptación en la tabla de `Empleados` y asignar los roles de `Supervisor`.

---

## Información Adicional

El **Proyecto Janus** incluye un **DER** con el diseño del proyecto, además de documentación sobre los requisitos y pasos para instalar la base de datos. Asegúrate de seguir la configuración detallada para garantizar el correcto funcionamiento del proyecto.

---

¡Gracias por elegirnos!  
**- Proyecto Janus**
