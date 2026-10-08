extends "res://Escenas/Moneda/moneda.gd"

@export var multiplicador_velocidad: float = 1.5
@export var duracion_buff: float = 5.0

func _ready() -> void:
	# Definimos el nombre del tipo de objeto para este script hijo
	tipo_objeto = "Milanga"
	# Ejecutamos el _ready del padre (moneda.gd) para conectar el body_entered
	super._ready()

func _on_body_entered(body: Node2D) -> void:
	if "player_id" in body:
		# 1. Aplica el buff de velocidad al jugador
		if body.has_method("aplicar_buff_velocidad"):
			body.aplicar_buff_velocidad(multiplicador_velocidad, duracion_buff)
		
		# 2. Registra el ítem "Milanga" en el ScoreManager con su valor
		ScoreManager.agregar_item(body.player_id, tipo_objeto, valor_objeto)
		
		# 3. Sonido y destrucción
		reproducir_sonido_y_destruir()
