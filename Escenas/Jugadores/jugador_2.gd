extends CharacterBody2D

# Configura este valor desde el Inspector (1 para P1, 2 para P2, etc.)
@export var player_id: int = 2
@export var fuerza_empuje: float = 80.0 # Fuerza para mover objetos pesados (RigidBody2D)

# --- SISTEMA DE VELOCIDAD Y BUFFS ---
@export var velocidad_base: float = 600.0
var velocidad: float = 600.0
var multiplicador_buff: float = 1.0
var timer_buff: SceneTreeTimer = null

# Referencias a baterías
var bateria_cercana: RigidBody2D = null    
var bateria_equipada: RigidBody2D = null

var cargador_cercano: Area2D = null
var colectivo_cercano: Area2D = null # La usaremos para el final

# Esta variable la asigna dinámicamente el PlayerManager para P3 y P4
var device_id: int = -1

var fuerza_salto := -800.0
var vida := 100
var ultima_direccion := Vector2(1, 0)

var gravedad: int = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variables para suavizar la animación de empuje y evitar el bug
var esta_empujando := false
var tiempo_empujando := 0.0
const MARGEN_EMPUJE := 0.15 # Tolerancia de 0.15s para que la animación no parpadee


func _ready() -> void:
	velocidad = velocidad_base
	add_to_group("jugador")
	$CartelTutorial.hide()


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
			var axis_x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
			if abs(axis_x) > 0.2: # Zona muerta
				direccion_x = axis_x

			if Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_LEFT):
				direccion_x = -1.0
			elif Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_RIGHT):
				direccion_x = 1.0

			quiere_saltar = Input.is_joy_button_pressed(device_id, JOY_BUTTON_A)

	# --- 3. SALTO Y MOVIMIENTO HORIZONTAL ---
	if quiere_saltar and is_on_floor():
		velocity.y = fuerza_salto

	if direccion_x != 0:
		velocity.x = direccion_x * velocidad
		ultima_direccion = Vector2(direccion_x, 0)
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)

	move_and_slide()

	# --- 4. DETECCIÓN Y PROCESAMIENTO DE EMPUJE ---
	var detecto_colision_caja := _procesar_empuje(direccion_x)

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
		if direccion_x == 0:
			esta_empujando = false
			tiempo_empujando = 0.0

		# Se eliminó 'agarrar'. Ahora prioriza empujar, correr o idle
		if esta_empujando:
			$AnimatedSprite2D.play("empujar")
		elif direccion_x != 0:
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("idle")


var esperando_accion: String = ""

func mostrar_ayuda(texto: String, accion_base: String):
	var accion_real = "p" + str(player_id) + "_" + accion_base
	esperando_accion = accion_real
	
	var nombre_boton = "Tecla"
	
	if player_id <= 2:
		if InputMap.has_action(accion_real):
			var eventos = InputMap.action_get_events(accion_real)
			if eventos.size() > 0:
				nombre_boton = eventos[0].as_text().get_slice(" (", 0)
		else:
			print("❌ ERROR: No encuentro la acción '", accion_real, "' en tu Input Map.")
	else:
		if accion_base == "saltar": nombre_boton = "Botón A"
		elif accion_base == "interactuar": nombre_boton = "Botón X"
	
	$CartelTutorial.text = "[" + nombre_boton + "] " + texto
	$CartelTutorial.show()


func apagar_ayuda():
	$CartelTutorial.hide()
	esperando_accion = ""


func _unhandled_input(event: InputEvent) -> void:
	var accion_interactuar = "p" + str(player_id) + "_interactuar"

	if esperando_accion != "" and event.is_action_pressed(esperando_accion):
		$CartelTutorial.hide()
		esperando_accion = ""
		
	if not event.is_action_pressed(accion_interactuar):
		return

	if bateria_equipada != null:
		if cargador_cercano != null and cargador_cercano.puede_recibir():
			cargador_cercano.recibir_bateria(self, bateria_equipada)
		else:
			bateria_equipada.ser_soltada()
		
		get_viewport().set_input_as_handled()
		return

	if bateria_cercana != null and bateria_equipada == null:
		bateria_cercana.ser_agarrada_por(self)
		get_viewport().set_input_as_handled()


func _procesar_empuje(direccion_x: float) -> bool:
	var empujando_caja := false

	for i in get_slide_collision_count():
		var colision := get_slide_collision(i)
		var objeto_colisionado := colision.get_collider()

		if objeto_colisionado is RigidBody2D:
			var normal_x = colision.get_normal().x
			
			if is_on_floor() and direccion_x != 0 and sign(direccion_x) == sign(-normal_x):
				var direccion_empuje := Vector2(-normal_x, 0)
				objeto_colisionado.apply_central_force(direccion_empuje * fuerza_empuje * 100.0)
				empujando_caja = true

	return empujando_caja


# --- APLICACIÓN SEGURA DE BUFFS DE VELOCIDAD ---
func aplicar_buff_velocidad(multiplicador: float, duracion: float) -> void:
	# 1. Aplica el multiplicador siempre basándose en la velocidad_base
	multiplicador_buff = multiplicador
	velocidad = velocidad_base * multiplicador_buff
	
	# 2. Resetea el timer previo para extender el tiempo al agarrar otro objeto
	if timer_buff != null:
		timer_buff = null
	
	# 3. Inicia el nuevo timer
	timer_buff = get_tree().create_timer(duracion)
	await timer_buff.timeout
	
	# 4. Restaura exactamente la velocidad base original
	multiplicador_buff = 1.0
	velocidad = velocidad_base
