extends Area2D
class_name Moneda

@export_enum("Moneda", "Milanga", "Juguito") var tipo_objeto: String = "Moneda"
@export var valor_objeto: int = 1

@onready var sonido_moneda: AudioStreamPlayer2D = $SonidoMoneda

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if "player_id" in body:
		ScoreManager.agregar_item(body.player_id, tipo_objeto, valor_objeto)
		reproducir_sonido_y_destruir()

func reproducir_sonido_y_destruir() -> void:
	visible = false
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		
	if sonido_moneda and sonido_moneda.stream:
		sonido_moneda.play()
		await sonido_moneda.finished
		
	queue_free()
