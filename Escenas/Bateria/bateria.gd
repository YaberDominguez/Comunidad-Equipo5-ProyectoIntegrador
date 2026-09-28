extends Area2D

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
	# Si ya tiene un dueño (es un robo)
	if duenio_actual != null:
		duenio_actual.bateria_equipada = null
	
	duenio_actual = nuevo_duenio
	duenio_actual.bateria_equipada = self
	
	# Si el nuevo dueño la tenía como "cercana", ya no lo está porque ahora la tiene en mano
	if duenio_actual.bateria_cercana == self:
		duenio_actual.bateria_cercana = null

	# La emparentamos al jugador y la centramos
	reparent(nuevo_duenio)
	position = Vector2(0, -20) # Ajustá la altura según el sprite de tu personaje

## Llamado por el jugador que la suelta
func ser_soltada() -> void:
	if duenio_actual == null:
		return

	var pos_global_suelo: Vector2 = global_position
	
	duenio_actual.bateria_equipada = null
	duenio_actual = null

	# La devolvemos a la raíz de la escena del nivel
	var nivel = get_tree().current_scene
	reparent(nivel)
	global_position = pos_global_suelo
