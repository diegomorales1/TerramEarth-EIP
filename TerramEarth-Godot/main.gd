extends Control

@onready var timer = $Timer

@onready var panel_sensores = $PanelSensores
@onready var panel_clasificador = $PanelClasificador
@onready var panel_alertas = $PanelAlertas
@onready var panel_telemetria = $PanelTelemetria
@onready var panel_salida = $PanelSalida
@onready var panel_data_set = $PanelDataSet
@onready var panel_bigquery = $PanelBigQuery
@onready var panel_vertex = $PanelVertexAI
@onready var panel_notificacion = $PanelNotificacion
@onready var panel_boletin = $PanelBoletin

@onready var panel_temp = $"PanelTemp"
@onready var panel_aceite = $"PanelAceite"
@onready var panel_luces = $"PanelLuces"
@onready var panel_presion = $"PanelPresion"
@onready var panel_gps = $"PanelGPS"
@onready var panel_rendimiento = $"PanelRendimiento"
@onready var panel_rpm = $"PanelRPM"

@onready var lineaTEMPSENS = $"CR TEMPSENS"
@onready var lineaACEITESENS = $"CR ACEITESENS"
@onready var lineaLUCESSENS = $"CR LUCESSENS"
@onready var lineaPRESIONSENS = $"CR PRESIONSENS"
@onready var lineaGPSSENS = $"CR GPSSENS"
@onready var lineaRENDIMIENTOSENS = $"CR RENDIMIENTOSENS"
@onready var lineaRPMSENS = $"CR RPMSENS"

@onready var label_temp = $"PanelTemp/LabelTemp"
@onready var label_aceite = $"PanelAceite/LabelAceite"
@onready var label_luces = $"PanelLuces/LabelLuces"
@onready var label_presion = $"PanelPresion/LabelPresion"
@onready var label_gps = $"PanelGPS/LabelGPS"
@onready var label_rendimiento = $"PanelRendimiento/LabelRendimiento"
@onready var label_rpm = $"PanelRPM/LabelRPM"

@onready var lineaSC = $"CR SC"
@onready var lineaTS = $"CR TS"
@onready var lineaCA = $"CR CA"
@onready var lineaAS = $"CR AS"
@onready var lineaCT = $"CR CT"
@onready var lineaTD = $"CR TD"
@onready var lineaDB = $"CR DB"
@onready var lineaBV = $"CR BV"
@onready var lineaNB = $"CR NB"
@onready var lineaBS = $"CR BS"

@onready var label_sensores = $PanelSensores/LabelSensores
@onready var label_clasificador = $PanelClasificador/LabelClasificador
@onready var label_alertas = $PanelAlertas/LabelAlertas
@onready var label_telemetria = $PanelTelemetria/LabelTelemetria
@onready var label_salida = $PanelSalida/LabelSalida
@onready var logs = $RichTextLabelLogs
@onready var label_dataset = $"PanelDataSet/LabelDataSet"
@onready var label_bigquery = $"PanelBigQuery/LabelBigQuery"
@onready var label_vertexai = $"PanelVertexAI/LabelVertexAI"
@onready var label_notificacion = $"PanelNotificacion/LabelNotificacion"
@onready var label_boletin = $"PanelBoletin/LabelBoletin"

var sensores = [
	"Temperatura del motor",
	"Aceite del motor",
	"Luces de cabina",
	"Presión hidráulica",
	"GPS de la máquina",
	"Rendimiento",
	"RPM"
]

var procesando = false


var http_request: HTTPRequest


func _ready():
	randomize()
	timer.timeout.connect(_on_timer_timeout)


	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)


	label_sensores.text = "Sensores\nEsperando datos..."
	label_clasificador.text = "Clasificador\nEsperando mensaje..."
	label_alertas.text = "Sistema Evaluador de Alertas\nSin alertas"
	label_telemetria.text = "Sistema Procesador de Telemetría\nSin datos"
	label_salida.text = "Salida\nEsperando resultado..."
	logs.text = "Sistema automatizado iniciado.\n\n"

func _on_timer_timeout():
	if procesando:
		return
	
	procesando = true
	await generar_evento_automatico()
	procesando = false

func generar_evento_automatico():
	resetear_colores()

	var sensor = sensores[randi() % sensores.size()]
	var valor = await generar_valor(sensor)

	label_sensores.text = "Sensores\n" + sensor + "\nValor: " + str(valor)
	agregar_log("Dato recibido desde sensor: " + sensor + " = " + str(valor))
	await activar(panel_sensores)
	await activar_linea(lineaSC)
	label_clasificador.text = "Clasificador\nAnalizando mensaje..."
	agregar_log("Clasificador analizando el dato...")
	await activar(panel_clasificador)

	var es_critico = evaluar_si_es_critico(sensor, valor)

	enviar_a_activemq(sensor, valor, es_critico)


	if es_critico:
		await procesar_alerta(sensor, valor)
	else:
		await procesar_telemetria(sensor)

func generar_valor(sensor):
	if sensor == "Temperatura del motor":
		var temp = randi_range(60,125)
		await activar(panel_temp)
		label_temp.text = "TEMP:\n" + str(temp) + "°"
		await activar_linea(lineaTEMPSENS)
		return temp
	elif sensor == "Aceite del motor":
		var aceite = randi_range(10, 100)
		await activar(panel_aceite)
		label_aceite.text = "ACEITE:\n" + str(aceite)
		await activar_linea(lineaACEITESENS)
		return aceite
	elif sensor == "Presión hidráulica":
		var presion = randi_range(20, 100)
		await activar(panel_presion)
		label_presion.text = "PRESION: \n" + str(presion)
		await activar_linea(lineaPRESIONSENS)
		return presion
	elif sensor == "RPM":
		var rpm = randi_range(800, 5200)
		await activar(panel_rpm)
		label_rpm.text = "RPM\n" + str(rpm)
		await activar_linea(lineaRPMSENS)
		return rpm
	elif sensor == "Rendimiento":
		var rendimiento = randi_range(40, 100)
		await activar(panel_rendimiento)
		label_rendimiento.text = "RENDIMIENTO\n" + str(rendimiento)
		await activar_linea(lineaRENDIMIENTOSENS)
		return rendimiento
	elif sensor == "GPS de la máquina":
		await activar(panel_gps)
		label_gps.text = "GPS:\nACTIVO"
		await activar_linea(lineaGPSSENS)
		return "Activo"
	elif sensor == "Luces de cabina":
		await activar(panel_luces)
		label_luces.text = "LUCES:\nOK"
		await activar_linea(lineaLUCESSENS)
		return "OK"
	else:
		return 0

func evaluar_si_es_critico(sensor, valor):
	if sensor == "Temperatura del motor" and valor > 100:
		label_clasificador.text = "Clasificador\nMensaje crítico"
		return true
	
	if sensor == "Aceite del motor" and valor < 25:
		label_clasificador.text = "Clasificador\nMensaje crítico"
		return true
	
	if sensor == "Presión hidráulica" and valor < 35:
		label_clasificador.text = "Clasificador\nMensaje crítico"
		return true
	
	if sensor == "RPM" and valor > 4500:
		label_clasificador.text = "Clasificador\nMensaje crítico"
		return true
	
	label_clasificador.text = "Clasificador\nMensaje operacional"
	return false

func procesar_alerta(sensor, valor):
	await activar_linea(lineaCA)
	agregar_log("ALERTA: dato crítico detectado.")
	
	label_alertas.text = "Sistema Evaluador de Alertas\n⚠ " + sensor + "\nValor crítico: " + str(valor)
	await activar(panel_alertas)
	await activar_linea(lineaAS)
	await activar(panel_notificacion)
	label_notificacion.text = "Notificación:\nENVIADA"
	agregar_log("Notificación enviada a los usuarios.")
	await activar_linea(lineaNB)
	await activar(panel_boletin)
	label_boletin.text = "Boletín:\nACTUALIZADO"
	agregar_log("Boletín técnico actualizado.\n")
	await activar_linea(lineaBS)
	label_salida.text = "Salida\nNotificación enviada\nBoletín técnico actualizado"
	await activar(panel_salida)
	label_notificacion.text = "Notificación"
	label_boletin.text = "Boletín"

func procesar_telemetria(sensor):
	await activar_linea(lineaCT)
	agregar_log("Dato operacional detectado.")
	
	label_telemetria.text = "Sistema Procesador de Telemetría\nProcesando " + sensor
	await activar(panel_telemetria)
	await activar_linea(lineaTD)
	await activar(panel_data_set)
	label_dataset.text = "Dataset:\nACTUALIZADO"
	agregar_log("Dataset actualizado.")
	await activar_linea(lineaDB)
	await activar(panel_bigquery)
	label_bigquery.text = "BigQuery:\nENVIADOS"
	agregar_log("Datos enviados a BigQuery.")
	await activar_linea(lineaBV)
	await activar(panel_vertex)
	label_vertexai.text = "Vertex AI:\nVERIFICACION EJECUTADA"
	agregar_log("Verificación ML ejecutada.\n")
	await activar_linea(lineaTS)
	label_salida.text = "Salida\nDataset actualizado\nBigQuery sincronizado\nVerificación ML ejecutada"
	await activar(panel_salida)
	label_dataset.text = "Dataset"
	label_bigquery.text = "BigQuery"
	label_vertexai.text = "Vertex AI"

func activar(panel):
	panel.modulate = Color(1, 1, 0.4)
	await get_tree().create_timer(0.7).timeout
	panel.modulate = Color(1, 1, 1)
	
func activar_linea(linea):
	linea.modulate = Color(1,1,0.4)
	await get_tree().create_timer(0.7).timeout
	linea.modulate = Color(1, 1, 1)

func resetear_colores():
	panel_sensores.modulate = Color(1, 1, 1)
	panel_clasificador.modulate = Color(1, 1, 1)
	panel_alertas.modulate = Color(1, 1, 1)
	panel_telemetria.modulate = Color(1, 1, 1)
	panel_salida.modulate = Color(1, 1, 1)

func agregar_log(texto):
	logs.append_text(texto + "\n")

# Funciones para la cola de mensajes ActiveMQ
func enviar_a_activemq(sensor, valor, es_critico):
	var http_temporal = HTTPRequest.new()
	add_child(http_temporal)
	http_temporal.request_completed.connect(_on_request_completed.bind(http_temporal))
	
	# hay que tener ojo aqui, se puso IP directa para que vayan con sincronia los sensores con la cola mq
	var url = "http://127.0.0.1:8161/api/message/TerramEarth_Datos?type=queue"
	var headers = [
		"Authorization: Basic YWRtaW46YWRtaW4=", 
		"Content-Type: application/json"
	]
	
	var body = JSON.stringify({
		"sensor": sensor,
		"valor": valor,
		"es_critico": es_critico
	})
	
	var error = http_temporal.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		agregar_log(">> Error interno en Godot al intentar enviar a ActiveMQ.")
		http_temporal.queue_free() 

func _on_request_completed(_result, response_code, _headers, _body, nodo_http):
	if response_code == 200:
		agregar_log(">> [ActiveMQ] Mensaje encolado con éxito.")
	else:
		agregar_log(">> [ActiveMQ] Fallo de conexión. Código: " + str(response_code))
	
	nodo_http.queue_free()
