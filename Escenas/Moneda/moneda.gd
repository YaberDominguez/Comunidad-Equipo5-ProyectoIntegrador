extends Area2D

@export var valor_moneda: int = 1

@onready var sonido_moneda: AudioStreamPlayer2D = $SonidoMoneda # Asegúrate de que el nodo se llame exactamente así

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if "player_id" in body:
		ScoreManager.agregar_puntos(body.player_id, valor_moneda)
		
		# Ocultamos la imagen y desactivamos la colisión inmediatamente
		visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		
		# Reproducimos el MP3 y esperamos a que termine
		if sonido_moneda and sonido_moneda.stream:
			sonido_moneda.play()
			await sonido_moneda.finished
			
		queue_free()
