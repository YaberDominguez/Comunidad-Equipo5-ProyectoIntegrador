extends CharacterBody2D

# Configura este valor desde el Inspector (1 para P1, 2 para P2, etc.)
@export var player_id: int = 2
@export var fuerza_empuje: float = 80.0 # Fuerza para mover objetos pesados (RigidBody2D)

# Referencias a baterías (Cambiado de Area2D a RigidBody2D)
var bateria_cercana: RigidBody2D = null    
var bateria_equipada: RigidBody2D = null

var cargador_cercano: Area2D = null
var colectivo_cercano: Area2D = null # La usaremos para el final
# Esta variable la asigna dinámicamente el PlayerManager para P3 y P4
var device_id: int = -1

var velocidad := 600.0
var fuerza_salto := -600.0
var vida := 100
var ultima_direccion := Vector2(1, 0)

var gravedad: int = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variables para suavizar la animación de empuje y evitar el bug
var esta_empujando := false
var tiempo_empujando := 0.0
const MARGEN_EMPUJE := 0.15 # Tolerancia de 0.15s para que la animación no parpadee


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
var esperando_accion: String = ""

func mostrar_ayuda(texto: String, accion: String):
	$CartelTutorial.text = texto
	$CartelTutorial.show()
	esperando_accion = accion

func _unhandled_input(event: InputEvent) -> void:
	# Detecta si se presionó la acción global "Interactuar"
	if esperando_accion != "" and event.is_action_pressed(esperando_accion):
		$CartelTutorial.hide()
		esperando_accion = "" # Ya lo completó
	if not event.is_action_pressed("p1_interactuar"):
		return

	# CASO 1: Si ya lleva una batería, la suelta o la pone en el cargador
	if bateria_equipada != null:
		if cargador_cercano != null and cargador_cercano.puede_recibir():
			# Si estamos en el cargador, se la entregamos
			cargador_cercano.recibir_bateria(self, bateria_equipada)
		else:
			# Si no hay cargador, la tira al piso normalmente
			bateria_equipada.ser_soltada()
		
		get_viewport().set_input_as_handled()
		return

	# CASO 2: Si hay una batería cerca (en el suelo O llevada por otro pj) y tiene las manos libres
	if bateria_cercana != null and bateria_equipada == null:
		bateria_cercana.ser_agarrada_por(self)
		get_viewport().set_input_as_handled()
# Función que aplica fuerza física al RigidBody2D y devuelve true si hay colisión activa de empuje

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
