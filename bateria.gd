extends Area2D

var jugador_actual: CharacterBody2D = null  # Quién la tiene en mano ahora
var ladron_en_rango: CharacterBody2D = null # Otro jugador cerca que puede robarla o levantarla
func _ready() -> void:
	add_to_group("Bateria")
	body_entered.connect(Interaccion_posible)
	body_exited.connect(Interaccion_no_posible)

func Interaccion_posible(body: Node2D) -> void:
	# Solo nos interesa si es un jugador y NO es quien ya la tiene agarrada
	if body.is_in_group("Jugador") and body != jugador_actual:
		ladron_en_rango = body

func Interaccion_no_posible(body: Node2D) -> void:
	if body == ladron_en_rango:
		ladron_en_rango = null

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("Interactuar"):
		return

	# caso base 1 cuando el jugador que lleva la bateria puede soltarla
	if jugador_actual != null:
		soltar()
		return
	#caso base 2 cuando la bateria esta en el piso o un jugador se acerca para poder robarla
	if ladron_en_rango != null:
		# Si el que intenta agarrar ya tiene otra batería en mano, no lo dejamos
		if ladron_en_rango.has_meta("tiene_bateria") and ladron_en_rango.get_meta("tiene_bateria") == true:
			return
		else:
			transferir_a(ladron_en_rango)

func transferir_a(nuevo_duenio: CharacterBody2D) -> void:
	# Si alguien ya la tenía, le quitamos la marca
	if jugador_actual != null:
		jugador_actual.set_meta("tiene_bateria", false)
	
	jugador_actual = nuevo_duenio
	jugador_actual.set_meta("tiene_bateria", true)
	ladron_en_rango = null
	
	# La emparientamos al nuevo dueño
	reparent(nuevo_duenio)
	position = Vector2.ZERO

func soltar() -> void:
	if jugador_actual == null:
		return

	# 1. Guardamos la posición global donde quedó el jugador antes de desvincularlo
	var pos_suelo: Vector2 = global_position
	
	# 2. Liberamos al jugador
	jugador_actual.set_meta("tiene_bateria", false)
	jugador_actual = null

	# 3. La devolvemos a la escena principal/nivel (el padre del jugador)
	var nivel = get_tree().current_scene
	reparent(nivel)
	global_position = pos_suelo
