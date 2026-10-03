extends RigidBody2D # <-- Cambiado a RigidBody2D

@export var funciona: bool = true
var duenio_actual: CharacterBody2D = null

# Referencia al Area2D que pusimos como hijo para detectar jugadores
@onready var area_deteccion: Area2D = $"Area de deteccion" 

func _ready() -> void:
	add_to_group("Bateria")
	
	# Conectamos las señales del Area2D HIJO, ya no del nodo raíz
	area_deteccion.body_entered.connect(_on_body_entered)
	area_deteccion.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	# Si la batería tiene un dueño, actualizamos de qué lado del cuerpo está
	if duenio_actual != null:
		var distancia_manos = 100.0 # <-- Ajustá este número para que quede justo en la mano
		
		# Leemos la variable que armaste en el jugador
		if duenio_actual.ultima_direccion.x < 0:
			position.x = -distancia_manos # Mira a la izquierda
		else:
			position.x = distancia_manos  # Mira a la derecha
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and body != duenio_actual:
		if "bateria_cercana" in body:
			body.bateria_cercana = self


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador") and "bateria_cercana" in body:
		if body.bateria_cercana == self:
			body.bateria_cercana = null


func ser_agarrada_por(nuevo_duenio: CharacterBody2D) -> void:
	if duenio_actual != null:
		duenio_actual.bateria_equipada = null
	
	duenio_actual = nuevo_duenio
	duenio_actual.bateria_equipada = self
	
	if duenio_actual.bateria_cercana == self:
		duenio_actual.bateria_cercana = null

	# 1. Congelamos las físicas (apaga la gravedad para que no se caiga ni empuje al jugador)
	freeze = true
	
	# 2. Desactivamos la colisión física contra el suelo
	_alternar_colision(true)

	reparent(nuevo_duenio)
	
	z_index = 10 # <-- Esto hace que se dibuje POR ENCIMA del personaje
	position.y = -10 # <-- Altura de la cintura/pecho. (Ajustá este número si la querés más arriba o abajo)
	rotation = 0 # La enderezamos por si cayó torcida


func ser_soltada() -> void:
	if duenio_actual == null:
		return

	var pos_global_suelo: Vector2 = global_position
	
	duenio_actual.bateria_equipada = null
	duenio_actual = null

	var nivel := get_tree().current_scene
	reparent(nivel)
	global_position = pos_global_suelo

	# 1. Descongelamos las físicas para que vuelva a actuar la gravedad
	freeze = false
	
	# 2. Reactivamos colisiones físicas con el suelo
	_alternar_colision(false)
# 1. Descongelamos las físicas para que vuelva a actuar la gravedad
	freeze = false
	
	# 2. Reactivamos colisiones físicas con el suelo
	_alternar_colision(false)
	
	z_index = 0 # <-- Le devolvemos el z_index normal para que no quede superpuesta mágicamente a otras cosas en el piso

func _alternar_colision(desactivar: bool) -> void:
	# Solo apagamos el CollisionShape2D principal (el del suelo), no el del Area2D
	if has_node("CollisionShape2D"):
		$"Colision fisica".set_deferred("disabled", desactivar)


func establecer_estado(esta_buena: bool) -> void:
	funciona = esta_buena
