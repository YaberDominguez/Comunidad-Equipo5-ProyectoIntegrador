extends Camera2D

@export var velocidad_suavizado: float = 8.0
@export var margen_borde: float = 50.0

func _ready() -> void:
	process_physics_priority = 100

func _physics_process(delta: float) -> void:
	# 1. Obtener nodos válidos y visibles del grupo "jugador"
	var todos_los_nodos = get_tree().get_nodes_in_group("jugador")
	var lista_validos: Array[CharacterBody2D] = []
	
	for nodo in todos_los_nodos:
		if is_instance_valid(nodo) and nodo is CharacterBody2D and nodo.is_visible_in_tree():
			if not lista_validos.has(nodo):
				lista_validos.append(nodo)
			
	if lista_validos.size() < 2:
		return

	# 2. Encontrar extremos (Jugador más a la izquierda y más a la derecha)
	var min_x: float = lista_validos[0].global_position.x
	var max_x: float = lista_validos[0].global_position.x
	var suma_y: float = 0.0

	for j in lista_validos:
		var pos_x = j.global_position.x
		if pos_x < min_x:
			min_x = pos_x
		if pos_x > max_x:
			max_x = pos_x
		suma_y += j.global_position.y

	# 3. Ancho útil disponible de la pantalla
	var tamano_pantalla = get_viewport_rect().size / zoom
	var media_pantalla_x = tamano_pantalla.x / 2.0
	var ancho_maximo_permitido = tamano_pantalla.x - (margen_borde * 2.0)

	# 4. Verificar si los jugadores ya están separados al límite máximo de la pantalla
	var centro_x = (min_x + max_x) / 2.0
	var centro_y = suma_y / lista_validos.size()
	
	var separacion_actual = max_x - min_x

	# Si la distancia entre el primero y el último es igual o mayor al ancho permitido,
	# bloqueamos la cámara en su X actual para que las paredes no se desplacen
	if separacion_actual >= ancho_maximo_permitido:
		# Si la cámara ya estaba centrada, fijamos el centro X para no arrastrar al otro jugador
		centro_x = global_position.x

	# 5. Aplicar posición a la cámara
	global_position.x = centro_x
	global_position.y = lerp(global_position.y, centro_y, velocidad_suavizado * delta)

	# 6. PAREDES INVISIBLES
	var limite_izquierdo = global_position.x - media_pantalla_x + margen_borde
	var limite_derecho = global_position.x + media_pantalla_x - margen_borde

	# El clamp ahora detendrá al jugador en movimiento contra la pared sin mover al otro
	for j in lista_validos:
		j.global_position.x = clamp(j.global_position.x, limite_izquierdo, limite_derecho)
