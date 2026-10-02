extends Area2D

@export var accion: String = "saltar" # Ej: si tenés un sistema dinámico, el player sabrá si es su saltar_p1 o p2
@export var texto: String = "¡Salta!"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		# Le decimos a ESE jugador que muestre su ayuda
		# Acá le pasás la acción. Si tenés Inputs separados, podés armar el string acá, ej: accion + "_" + body.id_jugador
		body.mostrar_ayuda(texto, accion)
