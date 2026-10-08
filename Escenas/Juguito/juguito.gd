extends "res://Escenas/Moneda/moneda.gd"

@export var multiplicador_velocidad: float = 1.5
@export var duracion_buff: float = 3.0

func _ready() -> void:
	tipo_objeto = "Juguito"
	super._ready()

func _on_body_entered(body: Node2D) -> void:
	if "player_id" in body:
		if body.has_method("aplicar_buff_velocidad"):
			body.aplicar_buff_velocidad(multiplicador_velocidad, duracion_buff)
		
		ScoreManager.agregar_item(body.player_id, tipo_objeto, valor_objeto)
		reproducir_sonido_y_destruir()
