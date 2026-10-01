extends Area2D

# 1. Variables para arrastrar tus PNGs desde el Inspector de Godot
@export var tex_vacio: Texture2D        # Arrastra "cargador VACÍO.png"
@export var tex_neutral: Texture2D      # Arrastra "batería neutral.png"
@export var tex_correcta: Texture2D     # Arrastra "batería correcta.png"
@export var tex_quemada: Texture2D      # Arrastra "batería quemada.png" (o "batería incorrecta.png")

# Referencia al Sprite del cargador
@onready var sprite: Sprite2D = $Sprite2D

@export var baterias_restantes: int = 4
var bateria_buena_encontrada: bool = false
var esta_ocupado: bool = false


func _ready() -> void:
	# Nos aseguramos de que empiece con la imagen vacía
	if tex_vacio != null:
		sprite.texture = tex_vacio
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		body.cargador_cercano = self


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador") and body.cargador_cercano == self:
		body.cargador_cercano = null


func puede_recibir() -> bool:
	return not esta_ocupado and not bateria_buena_encontrada


func recibir_bateria(jugador: CharacterBody2D, bateria: RigidBody2D) -> void:
	esta_ocupado = true
	jugador.bateria_equipada = null
	
	# Centramos la batería física, pero la hacemos INVISIBLE 
	# para que no se superponga con el dibujo del cargador
	bateria.reparent(self)
	bateria.global_position = global_position
	bateria.rotation = 0
	bateria.visible = false
	
	# --- ESTADO 1: NEUTRAL (Testeando) ---
	sprite.texture = tex_neutral
	
	# Le damos 1.5 segundos de suspenso mientras "evalúa" la batería
	await get_tree().create_timer(1.5).timeout
	
	# Calculamos las probabilidades
	var funciona := false
	if baterias_restantes <= 1:
		funciona = true
	else:
		if randi() % baterias_restantes == 0:
			funciona = true
			
	baterias_restantes -= 1
	
	if funciona:
		# --- ESTADO 2: ÉXITO ---
		bateria_buena_encontrada = true
		bateria.establecer_estado(true)
		
		# Cambiamos a luz verde
		sprite.texture = tex_correcta
		print("¡Batería funcional encontrada!")
		
		# Esperamos medio segundo para que los jugadores vean la luz verde
		await get_tree().create_timer(3).timeout
		
		# Escupimos la batería: la volvemos a hacer visible y la soltamos al piso
		bateria.visible = true
		bateria.ser_soltada() 
		
		# El cargador vuelve a quedar vacío (por si quieren mirarlo, aunque ya no se usa)
		sprite.texture = tex_vacio
		esta_ocupado = false 
		
	else:
		# --- ESTADO 3: FRACASO ---
		bateria.establecer_estado(false)
		
		# Cambiamos a luz roja y batería rota
		sprite.texture = tex_quemada
		print("La batería se quemó. Quedan: ", baterias_restantes)
		
		# Destruimos la batería física (ya no sirve para nada)
		bateria.queue_free()
		
		# Dejamos la luz roja de error por 2 segundos
		await get_tree().create_timer(3).timeout
		
		# Volvemos al estado vacío para que metan otra
		sprite.texture = tex_vacio
		esta_ocupado = false
