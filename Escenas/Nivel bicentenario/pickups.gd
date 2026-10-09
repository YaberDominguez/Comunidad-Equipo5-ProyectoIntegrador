extends Node2D

# ==============================================================================
# CONFIGURACIÓN DE PICKUPS (Moldes / Escenas .tscn)
# ==============================================================================
@export_group("Escenas de Pickups")
## Arrastra aquí desde el FileSystem la escena .tscn de tu primer pickup
@export var juguito: PackedScene
## Arrastra aquí la escena .tscn del segundo pickup
@export var milanga: PackedScene
## Arrastra aquí la escena .tscn del tercer pickup
@export var moneda: PackedScene


# ==============================================================================
# CANTIDADES A GENERAR
# ==============================================================================
@export_group("Cantidades a generar")
@export var cantidad_juguito: int = 8
@export var cantidad_milanga: int = 4
@export var cantidad_moneda: int = 10

# ==============================================================================
# REGLAS DE POSICIONAMIENTO Y FÍSICAS
# ==============================================================================
@export_group("Reglas de Spawning")
## Distancia en píxeles alrededor del objeto que debe estar 100% libre
@export var radio_seguridad: float = 24.0

## Intentos aleatorios antes de descartar el spawn si la zona ya está saturada
@export var max_intentos: int = 30

## Capas físicas con las que no debe chocar (Paredes, obstáculos, otros pickups).
## En el Inspector verás un selector desplegable con casillas para marcar tus capas.
@export_flags_2d_physics var collision_mask: int = 3

# ==============================================================================
# NODOS HIJOS Y VARIABLES INTERNAS
# ==============================================================================
## Si tu nodo Area2D en el árbol de escena tiene otro nombre, cámbialo aquí
@onready var spawn_area: Area2D = $AreadeSpawn

# Lista que almacena todos los CollisionShape2D hijos encontrados
var zonas_validas: Array[CollisionShape2D] = []


func _ready() -> void:
	_cargar_zonas_de_spawn()
	await get_tree().physics_frame
	generar_todos_los_pickups()


## Recorre los hijos de SpawnArea y guarda los rectángulos válidos
func _cargar_zonas_de_spawn() -> void:
	zonas_validas.clear()
	
	for hijo in spawn_area.get_children():
		if hijo is CollisionShape2D and not hijo.disabled and hijo.shape is RectangleShape2D:
			zonas_validas.append(hijo)


## Llama al proceso de spawn para cada tipo de pickup definido
func generar_todos_los_pickups() -> void:
	if zonas_validas.is_empty():
		push_warning("Spawner: No se encontraron CollisionShape2D con forma RectangleShape2D dentro de SpawnArea.")
		return
	
	_spawning_grupo(juguito, cantidad_juguito)
	_spawning_grupo(milanga, cantidad_milanga)
	_spawning_grupo(moneda, cantidad_moneda)


## Instancia la cantidad solicitada de una escena en posiciones libres
func _spawning_grupo(escena: PackedScene, cantidad: int) -> void:
	if not escena:
		return
	
	for i in range(cantidad):
		var pos_valida = _obtener_posicion_valida()
		
		# Si tras max_intentos no hubo espacio libre, salta al siguiente
		if pos_valida == Vector2.INF:
			continue
		
		var instancia = escena.instantiate()
		add_child(instancia)
		instancia.global_position = pos_valida


## Busca una coordenada libre dentro de cualquiera de los CollisionShape2D
func _obtener_posicion_valida() -> Vector2:
	var space_state = get_world_2d().direct_space_state

	# Preparamos la consulta con un círculo imaginario del tamaño de radio_seguridad
	var query = PhysicsShapeQueryParameters2D.new()
	var circulo_chequeo = CircleShape2D.new()
	circulo_chequeo.radius = radio_seguridad
	query.shape = circulo_chequeo
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = [spawn_area.get_rid()]

	for intento in range(max_intentos):
		# 1. Elige al azar una de las zonas disponibles
		var col_shape: CollisionShape2D = zonas_validas.pick_random()
		var rect: RectangleShape2D = col_shape.shape as RectangleShape2D
		
		var extents = rect.size / 2.0
		var pos_centro = col_shape.global_position

		# 2. Genera una coordenada al azar dentro del rectángulo elegido
		var test_x = randf_range(pos_centro.x - extents.x, pos_centro.x + extents.x)
		var test_y = randf_range(pos_centro.y - extents.y, pos_centro.y + extents.y)
		var punto_candidato = Vector2(test_x, test_y)

		# 3. Ubica la forma de prueba en ese punto y consulta el estado de físicas
		query.transform = Transform2D(0.0, punto_candidato)
		var colisiones = space_state.intersect_shape(query, 1)

		# Si no colisionó con nada en las capas seleccionadas, la posición es válida
		if colisiones.is_empty():
			return punto_candidato

	# Retorna infinito si se agotaron los intentos sin encontrar espacio libre
	return Vector2.INF
