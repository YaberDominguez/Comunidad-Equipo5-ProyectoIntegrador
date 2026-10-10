extends Control

@export var velocidad_scroll: float = 50.0
@export var escena_menu: String = "res://Escenas/Menu principal/menu_principal.tscn" # Cambia esto por la ruta de tu menú

@onready var texto = $RichTextLabel

func _ready():
	# Posiciona el texto justo debajo del borde inferior de la pantalla al iniciar
	texto.position.y = get_viewport_rect().size.y

func _process(delta):
	# Mueve el texto hacia arriba constantemente
	texto.position.y -= velocidad_scroll * delta
	
	# Detecta si el texto ya subió por completo para salir de la escena
	if texto.position.y < -texto.get_content_height():
		finalizar_creditos()

func _input(event):
	# Permite saltar los créditos presionando Escape, Enter o Espacio
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		finalizar_creditos()

func finalizar_creditos():
	get_tree().change_scene_to_file(escena_menu)
