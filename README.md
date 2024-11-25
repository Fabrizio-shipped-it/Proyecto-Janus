# Proyecto Janus

## Introducción

**Proyecto Janus** es un trabajo práctico de *Base de Datos Aplicada* cuyo objetivo es gestionar datos de productos y ventas de diferentes sucursales. A partir de una base de datos, el proyecto permite descargar productos desde archivos y registrar ventas realizadas en varias sucursales.

---

## Instrucciones de Instalación y Uso

El repositorio esta ordenado de tal forma que los scripts estan enumerado por orden de ejecución

1. **Ejecución del Creador de Tablas y Procedimientos Almacenados**
   - Primero, ejecute el script `CreadorDeTablasYSP`. Esto creará todas las tablas y SP necesarios para el correcto funcionamiento del proyecto. A su vez, esta disponible el `Lote de Pruebas` para que pueda probar el correcto funcionamiento de los diferentes SP. Se recomienda testear los SP antes de ejecutar los siguientes scripts.

2. **Ejecución de Importación**
   - El script `ImportacionDeArchivos` contiene el script para importar los archivos xlsx y csv, que rellenan las tablas del Proyecto.

3. **Ejecución de Reportes**
   - El script `Reportes` contiene el script para poder realizar reportes a partir de los datos almacenados.

4. **Ejecución del Archivo de Seguridad**
   - Finalmente, el script `SeguridadEncriptacion` ejecuta el archivo de seguridad para implementar la encriptación en la tabla de `Empleados` y asignar los roles de `Supervisor` a la tabla notaCredito.

---

## Información Adicional

El **Proyecto Janus** incluye un **DER** con el diseño del proyecto, además de documentación que contendra datos como los requisitos, pasos para instalar la base de datos, un plan de Backup, entre otros. Asegúrate de seguir la configuración detallada para garantizar el correcto funcionamiento del proyecto.

---

¡Gracias por elegirnos!  
**- Proyecto Janus**
