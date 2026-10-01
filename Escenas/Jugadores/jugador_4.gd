extends CharacterBody2D

@export var player_id: int = 4
@export var fuerza_empuje: float = 80.0

# Asigna este ID desde tu PlayerManager al instanciar al jugador (0 para el 1er mando, 1 para el 2do mando)
@export var device_id: int = -1 

# Referencias a baterías
var bateria_cercana: Area2D = null
var bateria_equipada: Area2D = null

var velocidad := 200.0
var fuerza_salto := -600.0
var vida := 100
var ultima_direccion := Vector2(1, 0)

var gravedad: int = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variables para animación de empuje
var esta_empujando := false
var tiempo_empujando := 0.0
const MARGEN_EMPUJE := 0.15

var prefix: String = ""

# Guardamos las entradas procesadas directamente desde eventos de este mando
var direccion_x: float = 0.0
var quiere_saltar: bool = false


func _ready() -> void:
	add_to_group("jugador")
	prefix = "p" + str(player_id) + "_"


func _physics_process(delta: float) -> void:
	# --- 1. GRAVEDAD ---
	if not is_on_floor():
		velocity.y += gravedad * delta

	# --- 2. LECTURA DE ENTRADAS SEPARADA ---
	@warning_ignore("shadowed_variable")
	var direccion_x := 0.0
	@warning_ignore("shadowed_variable")
	var quiere_saltar := false

	if player_id <= 2:
		# P1 y P2 usan Teclado desde el Input Map (acciones con prefijo p1_ / p2_)
		@warning_ignore("shadowed_variable")
		var prefix = "p" + str(player_id) + "_"
		direccion_x = Input.get_axis(prefix + "izquierda", prefix + "derecha")
		quiere_saltar = Input.is_action_just_pressed(prefix + "saltar")
	else:
		# P3 y P4 leen EXCLUSIVAMENTE del mando asignado a su device_id
		if device_id != -1:
			# Stick analógico izquierdo en X
			var axis_x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
			if abs(axis_x) > 0.2: # Zona muerta
				direccion_x = axis_x

			# Cruceta (D-Pad)
			if Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_LEFT):
				direccion_x = -1.0
			elif Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_RIGHT):
				direccion_x = 1.0

			# Botón A / X del mando para saltar
			quiere_saltar = Input.is_joy_button_pressed(device_id, JOY_BUTTON_A)

	# --- 3. SALTO Y MOVIMIENTO HORIZONTAL ---
	if quiere_saltar and is_on_floor():
		velocity.y = fuerza_salto

	if direccion_x != 0:
		velocity.x = direccion_x * velocidad
		ultima_direccion = Vector2(direccion_x, 0)
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)

	# Aplica el movimiento
	move_and_slide()

	# --- 4. DETECCIÓN Y PROCESAMIENTO DE EMPUJE ---
	var detecto_colision_caja := _procesar_empuje(direccion_x)

	# Lógica con margen de tiempo (Buffer) para solucionar el bug de animación
	if detecto_colision_caja:
		tiempo_empujando = MARGEN_EMPUJE
		esta_empujando = true
	else:
		if tiempo_empujando > 0:
			tiempo_empujando -= delta
			esta_empujando = true
		else:
			esta_empujando = false

	# --- 5. CONTROL DE ANIMACIONES ---
	if direccion_x != 0:
		$AnimatedSprite2D.flip_h = direccion_x < 0

	if not is_on_floor():
		$AnimatedSprite2D.play("saltar")
	else:
		# Si se deja de presionar el control horizontal, se cancela el empuje de inmediato
		if direccion_x == 0:
			esta_empujando = false
			tiempo_empujando = 0.0

		if esta_empujando:
			$AnimatedSprite2D.play("empujar")
		elif direccion_x != 0:
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("idle")

func _unhandled_input(event: InputEvent) -> void:
	# Construye el prefijo: "p1_" para P1, "p2_" para P2
	@warning_ignore("shadowed_variable")
	var prefix := "p" + str(player_id) + "_"
	
	# Verifica si se presionó la tecla de interactuar de ESTE jugador
	if event.is_action_pressed(prefix + "interactuar"):
		
		# CASO 1: Si ya tiene una batería equipada, la suelta
		if bateria_equipada != null:
			bateria_equipada.ser_soltada()
			get_viewport().set_input_as_handled()
			return

		# CASO 2: Si hay una batería cerca y tiene las manos libres, la agarra
		if bateria_cercana != null and bateria_equipada == null:
			bateria_cercana.ser_agarrada_por(self)
			get_viewport().set_input_as_handled()


@warning_ignore("shadowed_variable")
func _procesar_empuje(direccion_x: float) -> bool:
	var empujando_caja := false

	for i in get_slide_collision_count():
		var colision := get_slide_collision(i)
		var objeto_colisionado := colision.get_collider()

		# Comprueba si el objeto es de tipo RigidBody2D (como el Auto)
		if objeto_colisionado is RigidBody2D:
			# Calcula la dirección del impacto horizontal
			var normal_x = colision.get_normal().x
			
			# Verifica que el jugador esté en el suelo y caminando EN DIRECCIÓN al objeto
			if is_on_floor() and direccion_x != 0 and sign(direccion_x) == sign(-normal_x):
				var direccion_empuje := Vector2(-normal_x, 0)
				
				# Aplicamos FUERZA CONTINUA (no impulso)
				# 1 jugador = fuerza insuficiente | 2 jugadores = fuerza suficiente
				objeto_colisionado.apply_central_force(direccion_empuje * fuerza_empuje * 100.0)
				
				empujando_caja = true

	return empujando_caja
