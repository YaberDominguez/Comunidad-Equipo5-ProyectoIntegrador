extends Node

@onready var jugador_3: CharacterBody2D = $"../Jugador3"
@onready var jugador_4: CharacterBody2D = $"../Jugador4"

# Estado de las ranuras de los mandos
var jugadores = {
	3: {"nodo": null, "device": null},
	4: {"nodo": null, "device": null}
}

func _ready() -> void:
	jugadores[3]["nodo"] = jugador_3
	jugadores[4]["nodo"] = jugador_4

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.is_pressed():
		var device_id = event.device
		
		# --- CASO A: EL MANDO YA ESTÁ JUGANDO ---
		# Si presiona el botón START (JOY_BUTTON_START) o BACK (JOY_BUTTON_BACK), sale del juego.
		if event.button_index == JOY_BUTTON_START or event.button_index == JOY_BUTTON_BACK:
			if _mando_ya_registrado(device_id):
				_desactivar_jugador_por_mando(device_id)
				return

		# --- CASO B: EL MANDO NO ESTÁ JUGANDO ---
		# Si toca cualquier botón y no está registrado, intenta unirse
		if not _mando_ya_registrado(device_id):
			_activar_jugador(device_id)


func _mando_ya_registrado(device_id: int) -> bool:
	return jugadores[3]["device"] == device_id or jugadores[4]["device"] == device_id


func _activar_jugador(device_id: int) -> void:
	for p_id in [3, 4]:
		if jugadores[p_id]["device"] == null:
			jugadores[p_id]["device"] = device_id
			var nodo_p: CharacterBody2D = jugadores[p_id]["nodo"]
			
			if "device_id" in nodo_p:
				nodo_p.device_id = device_id
			
			# Activamos visibilidad y procesamiento
			nodo_p.process_mode = PROCESS_MODE_INHERIT
			nodo_p.show()
			
			print("¡Mando (Device ", device_id, ") activó al Jugador ", p_id, "!")
			break


func _desactivar_jugador_por_mando(device_id: int) -> void:
	for p_id in [3, 4]:
		if jugadores[p_id]["device"] == device_id:
			var nodo_p: CharacterBody2D = jugadores[p_id]["nodo"]
			
			# Ocultamos y pausamos el nodo del jugador
			nodo_p.process_mode = PROCESS_MODE_DISABLED
			nodo_p.hide()
			
			if "device_id" in nodo_p:
				nodo_p.device_id = -1
			
			# Liberamos la ranura
			jugadores[p_id]["device"] = null
			
			print("¡Mando (Device ", device_id, ") abandonó la partida. Jugador ", p_id, " liberado!")
			break
