#  TerramEarth: Sistema de Monitoreo y Telemetría IoT
**Evaluación sobre Integración de Procesos y Automatización (EIP)** *Proyecto de Ingeniería Civil Informática - Universidad Técnica Federico Santa María*

Equipo TP202602 Quemen el DFIS
---

##  Tabla de Contenidos
1. [Sección 1: Descripción del Proceso](#sección-1-descripción-del-proceso)
2. [Sección 2: Propuesta de Integración](#sección-2-propuesta-de-integración)
3. [Sección 3: Diagrama Representativo](#sección-3-diagrama-representativo)
4. [Sección 4: Implementación](#sección-4-implementación)
5. [Conclusión](#conclusión)
6. [Simulador Godot](#simulador-godot)

---

##  Sección 1: Descripción del Proceso

**Proceso seleccionado:** Sistema de Monitoreo y Telemetría IoT para Maquinaria Agrícola.

### Descripción del Proceso
El proceso central consiste en la captura, clasificación y distribución asíncrona de datos provenientes de sensores instalados en una flota de vehículos agrícolas (tractores, cosechadoras). Estos sensores generan flujos continuos de información (temperatura, presión, GPS, RPM, etc.) que ingresan a un sistema centralizado, donde un enrutador los clasifica en:
* **Datos Críticos (Tiempo Real):** Información de diagnóstico y errores inmediatos (ej. sobrecalentamiento). Requieren una acción urgente mediante notificaciones.
* **Datos Operacionales (Batch):** Información de telemetría y rendimiento recolectada durante la jornada laboral para análisis histórico.

### Relevancia de la Automatización
En la industria agrícola, la disponibilidad de la maquinaria es crítica, donde una falla mecánica en temporada de cosecha genera pérdidas económicas masivas. La automatización se justifica por:
1. **Volumen de Datos:** Procesar los millones de puntos de datos diarios generados por cada vehículo industrial.
2. **Reducción de Latencia:** La automatización asegura que un evento crítico dispare alertas instantáneas sin intervención humana.
3. **Mantenimiento Predictivo:** El flujo continuo hacia herramientas de análisis (Power BI) e Inteligencia Artificial permite predecir fallas antes de que ocurran.

---

##  Sección 2: Propuesta de Integración

Para solucionar el desafío de TerramEarth, se propone una arquitectura basada en **Patrones de Integración Empresarial (EIP)**, eliminando el acoplamiento fuerte y garantizando la resiliencia del sistema.

### Principios de Integración Aplicados

1. **Mensajería (Messaging / Message Broker):**
   Los sensores no escriben directamente en bases de datos. Utilizan **Apache ActiveMQ** como intermediario, publicando mensajes en colas de forma asíncrona bajo el patrón *Fire and Forget*. Esto permite que el hardware del tractor siga operando sin latencia.
2. **Enrutador por Contenido (Content-Based Router):**
   Un orquestador inspecciona el contenido del mensaje. Si es crítico, se deriva al sistema de alertas; si es operacional, al pipeline de almacenamiento.

### Comparación de Componentes de Integración en el Ecosistema

| Principio EIP | Aplicación en el Proyecto TerramEarth | Ventaja Arquitectónica |
| :--- | :--- | :--- |
| **Mensajería** | Uso de ActiveMQ para recibir el flujo concurrente de los tractores. | Soporta picos masivos de datos, generando **desacoplamiento** y tolerancia a fallos. |
| **Transferencia de Archivos** | Empaquetado de datos (Avro para críticos, Parquet para operacionales) hacia un Bucket Minio GS. | Optimiza los costos y estandariza el consumo de grandes volúmenes de datos históricos. |
| **Bases de Datos Compartidas** | Ingesta hacia BigQuery, actuando como Data Warehouse centralizado. | Elimina silos de información; analistas e ingenieros consumen la misma *fuente de verdad*. |
| **Invocación de Procedimiento Remoto (RPC)** | Llamadas a la API de Vertex AI para consultar modelos de Machine Learning. | Permite usar algoritmos complejos en la nube sin procesarlos localmente en la maquinaria. |

---

##  Sección 3: Diagrama Representativo

La solución se divide en dos perspectivas arquitectónicas para comprender tanto la infraestructura general como el flujo lógico de integración.

### 1. Arquitectura Cloud General
Este diagrama ilustra la infraestructura de alto nivel, mostrando el flujo desde la recolección en los vehículos hasta la explotación de datos en herramientas de inteligencia de negocios e IA.

![Arquitectura Cloud TerramEarth](/TerramEarth_General.png)


### 2. Diagrama de Patrones de Integración (Notación EIP)
Este diagrama detalla la lógica interna utilizando la notación estándar de Integración de Procesos Empresariales:

![Diagrama EIP TerramEarth](/EIP.TerramEarth.drawio.png)


**Elementos EIP Destacados:**
* **Message Endpoint:** Los sensores IoT (simulados) originando los datos.
* **Message Channel:** Las colas de ActiveMQ transportando la información.
* **Content-Based Router:** El "Evaluador de Alertas" que bifurca el flujo según criticidad.
* **Message Translator:** Apache Beam transformando mensajes a formatos Parquet/Avro.
* **Publish-Subscribe:** Distribución de datos a múltiples consumidores (Notificaciones, BigQuery, Vertex AI).

---

##  Sección 4: Implementación

### Plan de Despliegue
Para llevar a cabo la solución, se estructuran las siguientes fases:
1. **Capa Edge (Borde):** Instalación del cliente IoT en los tractores para capturar y empaquetar lecturas en JSON.
2. **Capa Middleware:** Despliegue de Apache ActiveMQ en el puerto `8161/61616`. Configuración de colas como `TerramEarth_Datos`.
3. **Capa de Procesamiento:** Orquestación de pipelines ETL en Apache Beam para consumir asíncronamente desde ActiveMQ.
4. **Capa de Almacenamiento y Explotación:** Volcado en BigQuery y conexión final con tableros de Power BI para los analistas.

### Desafíos y Soluciones Anticipadas

| Desafío Anticipado | Solución Propuesta (EIP) |
| :--- | :--- |
| **Pérdida de señal en zonas rurales** | Implementar un almacenando de mensajes localmente en el tractor hasta recuperar red. |
| **Cuellos de botella en la ingesta** | ActiveMQ actúa como *buffer* para que los sistemas de destino procesen a su propio ritmo. |
| **Cambios en el formato del sensor** | Uso de Pipelines para normalizar cualquier estructura nueva antes de su guardado en BigQuery. |

---

##  Conclusión

La automatización de ecosistemas industriales complejos como TerramEarth demuestra que las conexiones directas punto a punto son ineficientes y frágiles. La aplicación rigurosa de los **Principios de Integración Empresarial (EIP)** es fundamental para construir arquitecturas robustas y escalables. 

Al introducir intermediarios de mensajería (Message Brokers) y enrutadores lógicos, se logra un ecosistema altamente **desacoplado**. Esto garantiza que el hardware en terreno opere de forma asíncrona y segura, viabilizando el objetivo principal del negocio. Pasar de un mantenimiento reactivo a un modelo predictivo, asegurando que el dato correcto llegue al sistema adecuado en el momento preciso.

---

##  Simulador Godot

Este repositorio incluye una simulación desarrollada en el motor Godot que emula el comportamiento de los sensores de la maquinaria y su integración con el Message Broker.

**Requisitos para ejecutar:**
1. Instalar y ejecutar [Apache ActiveMQ Classic](https://activemq.apache.org/components/classic/download/).
2. Iniciar el servidor local (`bin/activemq start` o `./activemq console`).
3. Ejecutar el proyecto en Godot. El script enviará automáticamente peticiones asíncronas vía API REST (`127.0.0.1:8161`) a la cola `TerramEarth_Datos`.
