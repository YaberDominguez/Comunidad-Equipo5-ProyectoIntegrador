extends Camera2D

var jugador1: CharacterBody2D = null
var jugador2: CharacterBody2D = null

@export var velocidad_suavizado: float = 5.0

# --- NUEVA VARIABLE: Margen de seguridad en píxeles ---
# Evita que el personaje toque el borde exacto de la pantalla (se detiene un poco antes)
@export var margen_borde: float = 30.0

func _ready() -> void:
	process_physics_priority = 100 # <-- AGREGAR ESTA LÍNEA
	await get_tree().process_frame
	
	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.size() >= 2:
		jugador1 = jugadores[0]
		jugador2 = jugadores[1]
	else:
		print("⚠️ Alerta: ¡Se necesitan al menos 2 jugadores en el grupo 'jugador'!")

func _physics_process(delta: float) -> void:
	if is_instance_valid(jugador1) and is_instance_valid(jugador2):
		# 1. Mover la cámara al punto medio
		var punto_medio = (jugador1.global_position + jugador2.global_position) / 2.0
		global_position = global_position.lerp(punto_medio, velocidad_suavizado * delta)
		
		# 2. --- CÓDIGO DE CHOQUE CON LA CÁMARA ---
		# Calculamos qué tamaño tiene la pantalla actual en píxeles
		var tamano_pantalla = get_viewport_rect().size / zoom
		
		# Calculamos los límites exactos (Izquierda y Derecha) de lo que la cámara ve ahora
		var limite_izquierdo = global_position.x - (tamano_pantalla.x / 2.0) + margen_borde
		var limite_derecho = global_position.x + (tamano_pantalla.x / 2.0) - margen_borde
		
		# Aplicamos el límite al Jugador 1
		jugador1.global_position.x = clamp(jugador1.global_position.x, limite_izquierdo, limite_derecho)
		
		# Aplicamos el límite al Jugador 2
		jugador2.global_position.x = clamp(jugador2.global_position.x, limite_izquierdo, limite_derecho)
