extends Area2D

# Referencia a la UI (puedes asignarla desde el Inspector de Godot)
@export var ui_control: Control

# Listas para rastrear a los jugadores presentes y el estado de la batería
var jugadores_en_zona: Array[CharacterBody2D] = []
var tiene_bateria_buena: bool = false


func _ready() -> void:
	add_to_group("Combi")
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


# --- DETECCIÓN DE BATERÍAS (Area2D) ---
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Bateria"):
		if "funciona" in area and area.funciona == true:
			tiene_bateria_buena = true
			print("🚌 Batería funcional colocada en la combi.")
			siguiente_nivel()


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Bateria"):
		if "funciona" in area and area.funciona == true:
			tiene_bateria_buena = false
			print("🚌 Batería colocada a la combi.")


# --- DETECCIÓN DE JUGADORES (CharacterBody2D) ---
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and body is CharacterBody2D:
		if not jugadores_en_zona.has(body):
			jugadores_en_zona.append(body)
			
			var requeridos: int = obtener_total_jugadores_activos()
			print("🚌 Jugador ingresó a la combi (", jugadores_en_zona.size(), "/", requeridos, ")")
			siguiente_nivel()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador") and body is CharacterBody2D:
		if jugadores_en_zona.has(body):
			jugadores_en_zona.erase(body)
			print("🚌 Jugador salió de la combi.")


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
func siguiente_nivel(_body: CharacterBody2D = null) -> void:
	var requeridos: int = obtener_total_jugadores_activos()
	var todos_en_el_area: bool = jugadores_en_zona.size() >= requeridos

	if tiene_bateria_buena and todos_en_el_area:
		print("🎉 ¡Nivel completado! Guardando datos en ScoreManager...")
		
		# Guardamos los jugadores activos en el Autoload
		ScoreManager.jugadores_activos = requeridos

		# Cambiamos a la escena de resultados
		get_tree().change_scene_to_file("res://Escenas/PantalladeResultados/pantalla_resultados.tscn")
