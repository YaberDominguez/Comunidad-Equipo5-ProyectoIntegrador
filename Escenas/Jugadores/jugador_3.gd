extends CharacterBody2D

# Configura este valor desde el Inspector (1 para P1, 2 para P2, etc.)
@export var player_id: int = 3
@export var fuerza_empuje: float = 80.0 # Fuerza para mover objetos pesados (RigidBody2D)

# Esta variable la asigna dinámicamente el PlayerManager para P3 y P4
var device_id: int = -1

var velocidad := 200.0
var fuerza_salto := -600.0
var vida := 100
var ultima_direccion := Vector2(1, 0)

var gravedad: int = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variable de estado para controlar la animación
var esta_empujando := false


func _ready() -> void:
	add_to_group("jugador")


func _physics_process(delta: float) -> void:
	# --- 1. GRAVEDAD ---
	if not is_on_floor():
		velocity.y += gravedad * delta

	# --- 2. LECTURA DE ENTRADAS SEPARADA ---
	var direccion_x := 0.0
	var quiere_saltar := false

	if player_id <= 2:
		# P1 y P2 usan Teclado desde el Input Map (acciones con prefijo p1_ / p2_)
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

	# --- 4. EMPUJAR OBJETOS (RigidBody2D) ---
	esta_empujando = false
	_procesar_empuje(direccion_x)

	# --- 5. CONTROL DE ANIMACIONES ---
	if direccion_x != 0:
		$AnimatedSprite2D.flip_h = direccion_x < 0

	if not is_on_floor():
		$AnimatedSprite2D.play("saltar")
	else:
		if esta_empujando:
			$AnimatedSprite2D.play("empujar")
		elif direccion_x != 0:
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("idle")


# Función para interactuar físicamente y actualizar el estado de empuje
func _procesar_empuje(direccion_x: float) -> void:
	for i in get_slide_collision_count():
		var colision := get_slide_collision(i)
		var objeto_colisionado := colision.get_collider()

		# Comprueba si el objeto es de tipo RigidBody2D
		if objeto_colisionado is RigidBody2D:
			# Calcula la dirección del impacto horizontal
			var normal_x = colision.get_normal().x
			var direccion_empuje := Vector2(-normal_x, 0)
			
			# Aplicar fuerza física a la caja
			objeto_colisionado.apply_central_impulse(direccion_empuje * fuerza_empuje)
			
			# Si el jugador está en el suelo y camina en dirección a la caja, activa la animación
			if is_on_floor() and sign(direccion_x) == sign(-normal_x):
				esta_empujando = true
