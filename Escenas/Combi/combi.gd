extends Area2D

# Referencia a la UI (puedes asignarla desde el Inspector de Godot)
@export var ui_control: Control

# Lista para rastrear a los jugadores presentes
var jugadores_en_zona: Array[CharacterBody2D] = []


func _ready() -> void:
	add_to_group("Combi")
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Eliminamos area_entered y area_exited porque la batería ahora es un RigidBody2D


# --- DETECCIÓN DE ENTRADAS Y SALIDAS ---
func _on_body_entered(body: Node2D) -> void:
	# Si entra un jugador
	if body.is_in_group("jugador") and body is CharacterBody2D:
		if not jugadores_en_zona.has(body):
			jugadores_en_zona.append(body)
			
			var requeridos: int = obtener_total_jugadores_activos()
			print("🚌 Jugador ingresó a la combi (", jugadores_en_zona.size(), "/", requeridos, ")")
			siguiente_nivel()
			
	# Si tiran una batería al piso de la combi
	elif body.is_in_group("Bateria"):
		print("🚌 Batería detectada en el piso de la combi.")
		siguiente_nivel()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador") and body is CharacterBody2D:
		if jugadores_en_zona.has(body):
			jugadores_en_zona.erase(body)
			print("🚌 Jugador salió de la combi.")
			
	elif body.is_in_group("Bateria"):
		print("🚌 Batería sacada de la combi.")


# --- OPCIÓN B: Cuenta solo a los jugadores con activo == true ---
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


# --- VERIFICACIÓN DE VICTORIA ---
func siguiente_nivel() -> void:
	var requeridos: int = obtener_total_jugadores_activos()
	var todos_en_el_area: bool = jugadores_en_zona.size() >= requeridos
	
	var tiene_bateria_buena: bool = false
	
	# PASO 1: Revisar si algún jugador que está en la combi la tiene en la mano
	for jugador in jugadores_en_zona:
		if "bateria_equipada" in jugador and jugador.bateria_equipada != null:
			if "funciona" in jugador.bateria_equipada and jugador.bateria_equipada.funciona:
				tiene_bateria_buena = true
				break
	
	# PASO 2: Si nadie la tiene en la mano, revisar si la dejaron tirada en el piso
	if not tiene_bateria_buena:
		var cosas_adentro = get_overlapping_bodies()
		for objeto in cosas_adentro:
			if objeto.is_in_group("Bateria") and "funciona" in objeto and objeto.funciona:
				tiene_bateria_buena = true
				break

	# PASO 3: Evaluar si ganaron
	if tiene_bateria_buena and todos_en_el_area:
		print("🎉 ¡Nivel completado! Guardando datos en ScoreManager...")
		
		# Guardamos los jugadores activos en el Autoload
		ScoreManager.jugadores_activos = requeridos

		# Cambiamos a la escena de resultados
		get_tree().change_scene_to_file("res://Escenas/PantalladeResultados/pantalla_resultados.tscn")
