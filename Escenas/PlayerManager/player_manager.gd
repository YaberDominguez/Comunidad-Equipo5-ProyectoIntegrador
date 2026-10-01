extends Node

@onready var jugador_3: CharacterBody2D = $"../Jugador3"
@onready var jugador_4: CharacterBody2D = $"../Jugador4"

# Diccionario para rastrear el ID exacto de mando asignado a cada jugador
var jugadores = {
	3: {"nodo": null, "device": null},
	4: {"nodo": null, "device": null}
}

func _ready() -> void:
	jugadores[3]["nodo"] = jugador_3
	jugadores[4]["nodo"] = jugador_4
	
	# Aseguramos que los jugadores empiecen desactivados y sin mando asignado
	for p_id in [3, 4]:
		var nodo_p: CharacterBody2D = jugadores[p_id]["nodo"]
		if nodo_p:
			nodo_p.process_mode = PROCESS_MODE_DISABLED
			nodo_p.hide()
			if "device_id" in nodo_p:
				nodo_p.device_id = -1


func _unhandled_input(event: InputEvent) -> void:
	# Escucha únicamente pulsaciones de botones de mandos (evita que se active por ejes o teclado)
	if event is InputEventJoypadButton and event.is_pressed():
		var event_device = event.device
		
		# Si este mando aún NO está registrado, se une a la primera ranura libre
		if not _mando_ya_registrado(event_device):
			_activar_primer_libre(event_device)
			get_viewport().set_input_as_handled()


func _mando_ya_registrado(device_id: int) -> bool:
	return jugadores[3]["device"] == device_id or jugadores[4]["device"] == device_id


func _activar_primer_libre(device_id: int) -> void:
	for p_id in [3, 4]:
		if jugadores[p_id]["device"] == null:
			# 1. Registramos el mando en el diccionario
			jugadores[p_id]["device"] = device_id
			var nodo_p: CharacterBody2D = jugadores[p_id]["nodo"]
			
			if nodo_p:
				# 2. Asignamos PRIMERO el ID del mando antes de activar el procesamiento
				if "device_id" in nodo_p:
					nodo_p.device_id = device_id
				
				# 3. Activamos el nodo
				nodo_p.process_mode = PROCESS_MODE_INHERIT
				nodo_p.show()
			
			# 4. Notificamos al gestor de puntuación
			if Engine.has_singleton("ScoreManager") or ScoreManager:
				ScoreManager.activar_jugador(p_id)
			
			print("-> Mando ID ", device_id, " asignado con éxito al Jugador ", p_id)
			return
