# ThreatLog-AI-AWS
Proyecto para procesar y automatizar los logs:
El siguiente proyecto que será utilizando Python consiste en procesar y automatizar todos los datos nuevos en S3, con Python se conectará a cada uno de los servicios de AWS que necesitamos para hacer la automatización de todo el proceso de los datos.

En este proyecto se consumirá pocos recursos ya que se irá llamando a cada uno de los servicios de AWS para ejecutar su respectiva tarea.

¿Es necesario utilizar un framework como Flask para desarrollar una API REST para enviar peticiones al proyecto de frontend?
No, es más en ningún momento la aplicación estará conectado con el frontend solamente estará conectado con AWS y sus diferentes servicios ya que la parte de enviar y recibir peticiones HTTP lo hará un servicio de AWS llamado AWS Gateway que hará de api y también incluye su propio servidor Websockets.

¿Es recomendable tener una aplicación hecha en Python para conectarse a diferentes servicios de AWS?
Si es muy recomendable que se haga de esta manera ya que de esta manera se consigue tanto escalabilidad y flexibilidad.
