extends Area2D

@export var accion_tutorial: String = "interactuar" 
@export var texto_tutorial: String = "¡Agarrá la batería!"
@export var mensaje_largo: String = ""
@export var offset_mensaje: Vector2 = Vector2.ZERO 

var jugadores_adentro: int = 0

func _ready():
	#body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if has_node("Mensaje"):
		if mensaje_largo != "":
			$Mensaje.text = mensaje_largo
		$Mensaje.position += offset_mensaje
		$Mensaje.hide() # Lo escondemos al arrancar por las dudas

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		jugadores_adentro += 1
		
		if body.has_method("mostrar_ayuda"):
			body.mostrar_ayuda(texto_tutorial, accion_tutorial)
			
		if has_node("Mensaje"):
			$Mensaje.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		jugadores_adentro -= 1
		
		# Apagamos el cartelito de la cabeza del jugador
		if body.has_method("apagar_ayuda"):
			body.apagar_ayuda()
		
		# Si ya no quedan jugadores en la zona...
		if jugadores_adentro <= 0:
			jugadores_adentro = 0 # Evita números negativos por las dudas
			
			if has_node("Mensaje"):
				$Mensaje.hide() # Obligamos al texto largo a desaparecer
			
			queue_free() # Destruimos la zona
