extends Area2D

@export var ui_control: Control
@onready var animated_sprite: AnimatedSprite2D = $Apariencia
@onready var sonido_averia: AudioStreamPlayer2D = $SonidoAveria
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D # <--- Nodo notificador de pantalla

var jugadores_en_zona: Array[CharacterBody2D] = []
var nivel_completado: bool = false
var combi_en_pantalla: bool = false # Controla si la combi es visible


func _ready() -> void:
	add_to_group("Combi")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Conectamos las señales de visibilidad en pantalla
	if notifier:
		notifier.screen_entered.connect(_on_screen_entered)
		notifier.screen_exited.connect(_on_screen_exited)
	
	if animated_sprite:
		animated_sprite.play("espera")


# --- DETECCIÓN DE VISIBILIDAD EN PANTALLA ---
func _on_screen_entered() -> void:
	combi_en_pantalla = true
	# Si entran en pantalla y aún no ganaron ni tienen la batería buena, intentamos reproducir la falla
	siguiente_nivel()

func _on_screen_exited() -> void:
	combi_en_pantalla = false
	# Si la combi sale de la vista de los jugadores, pausamos el sonido
	_detener_falla()


# --- DETECCIÓN DE ENTRADAS Y SALIDAS DE JUGADORES ---
func _on_body_entered(body: Node2D) -> void:
	if nivel_completado:
		return

	if body.is_in_group("jugador") and body is CharacterBody2D:
		if not jugadores_en_zona.has(body):
			jugadores_en_zona.append(body)
			var requeridos: int = obtener_total_jugadores_activos()
			print("🚌 Jugador ingresó a la combi (", jugadores_en_zona.size(), "/", requeridos, ")")
			siguiente_nivel()
			
	elif body.is_in_group("Bateria"):
		if "funciona" in body and body.funciona:
			print("🔋 Batería BUENA detectada en el piso de la combi.")
			siguiente_nivel()
		else:
			print("❌ Tiraron una batería ROTA en la combi.")
			siguiente_nivel()


func _on_body_exited(body: Node2D) -> void:
	if nivel_completado:
		return

	if body.is_in_group("jugador") and body is CharacterBody2D:
		if jugadores_en_zona.has(body):
			jugadores_en_zona.erase(body)
			print("🚌 Jugador salió de la combi.")
			siguiente_nivel()


# --- JUGADORES ACTIVOS ---
func obtener_total_jugadores_activos() -> int:
	var total_activos: int = 0
	var lista_jugadores: Array = get_tree().get_nodes_in_group("jugador")

	for jugador in lista_jugadores:
		var esta_activo: bool = false
		if "activo" in jugador:
			esta_activo = jugador.activo
		else:
			esta_activo = jugador.visible and jugador.is_physics_processing()

		if esta_activo:
			total_activos += 1

	return max(2, total_activos)


# --- VERIFICACIÓN DE VICTORIA Y CONTROL DE SONIDO ---
func siguiente_nivel() -> void:
	if nivel_completado:
		return

	var requeridos: int = obtener_total_jugadores_activos()
	var todos_en_el_area: bool = jugadores_en_zona.size() >= requeridos
	var tiene_bateria_buena: bool = false
	
	# PASO 1: Batería en la mano
	for jugador in jugadores_en_zona:
		if "bateria_equipada" in jugador and jugador.bateria_equipada != null:
			if "funciona" in jugador.bateria_equipada and jugador.bateria_equipada.funciona:
				tiene_bateria_buena = true
				break
	
	# PASO 2: Batería en el piso
	if not tiene_bateria_buena:
		var cosas_adentro = get_overlapping_bodies()
		for objeto in cosas_adentro:
			if objeto.is_in_group("Bateria") and "funciona" in objeto and objeto.funciona:
				tiene_bateria_buena = true
				break

	# PASO 3: Evaluar resultado
	if tiene_bateria_buena and todos_en_el_area:
		nivel_completado = true
		_detener_falla()
		print("🎉 ¡Nivel completado! Arrancando la combi...")
		_animar_salida_y_cambiar_escena(requeridos)
	else:
		# Solo suena la falla si la combi está en pantalla
		if combi_en_pantalla:
			_reproducir_falla()
		else:
			_detener_falla()


# --- CONTROL DE AUDIO ---
func _reproducir_falla() -> void:
	if sonido_averia and not sonido_averia.playing:
		sonido_averia.play()

func _detener_falla() -> void:
	if sonido_averia and sonido_averia.playing:
		sonido_averia.stop()


# --- ANIMACIÓN Y TRANSICIÓN ---
func _animar_salida_y_cambiar_escena(requeridos: int) -> void:
	for jugador in jugadores_en_zona:
		jugador.hide()
		jugador.set_physics_process(false)

	if animated_sprite:
		animated_sprite.stop()
		animated_sprite.play("arrancar")

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:x", position.x + 1200, 2.5)

	tween.finished.connect(func():
		ScoreManager.jugadores_activos = requeridos
		get_tree().change_scene_to_file("res://Escenas/PantalladeResultados/pantalla_resultados.tscn")
)
