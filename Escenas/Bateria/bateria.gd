extends Area2D

# Variable para definir si esta batería sirve o no (puedes cambiarlo en el Inspector)
@export var funciona: bool = true

# Referencia al jugador que la lleva puesta actualmente (null si está en el suelo)
var duenio_actual: CharacterBody2D = null


func _ready() -> void:
	add_to_group("Bateria")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	# Si un jugador entra al rango y no es el dueño actual, le avisamos que puede agarrarla/robarla
	if body.is_in_group("jugador") and body != duenio_actual:
		if "bateria_cercana" in body:
			body.bateria_cercana = self


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador") and "bateria_cercana" in body:
		if body.bateria_cercana == self:
			body.bateria_cercana = null


## Llamado por el jugador que intenta agarrar o robar
func ser_agarrada_por(nuevo_duenio: CharacterBody2D) -> void:
	# Si ya tiene un dueño (es un robo), liberamos al jugador anterior
	if duenio_actual != null:
		duenio_actual.bateria_equipada = null
	
	duenio_actual = nuevo_duenio
	duenio_actual.bateria_equipada = self
	
	# Si el nuevo dueño la tenía como "cercana", limpiamos la variable
	if duenio_actual.bateria_cercana == self:
		duenio_actual.bateria_cercana = null

	# Desactivamos la colisión temporalmente para evitar tirones de física mientras se carga
	_alternar_colision(true)

	# La emparentamos al nuevo jugador y la centramos sobre sus hombros/espalda
	reparent(nuevo_duenio)
	position = Vector2(0, -20) # Ajusta la altura según el sprite del personaje


## Llamado por el jugador que la suelta
func ser_soltada() -> void:
	if duenio_actual == null:
		return

	var pos_global_suelo: Vector2 = global_position
	
	duenio_actual.bateria_equipada = null
	duenio_actual = null

	# La devolvemos a la raíz de la escena del nivel
	var nivel := get_tree().current_scene
	reparent(nivel)
	global_position = pos_global_suelo

	# Reactivamos la colisión para que vuelva a ser detectable en el suelo
	_alternar_colision(false)


# Función auxiliar para activar/desactivar el CollisionShape2D de forma segura
func _alternar_colision(desactivar: bool) -> void:
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", desactivar)

# Agrega esta pequeña función al final de tu script de Bateria.gd
func establecer_estado(esta_buena: bool) -> void:
	funciona = esta_buena
	# Opcional: Si quieres diferenciar visualmente la buena de las falsas para depurar:
	if not funciona:
		modulate = Color(0.8, 0.8, 0.8) # Un poco más oscura si es falsa
