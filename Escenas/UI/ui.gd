extends Control

# Referencias a los nodos Label creados en la escena
@onready var label_p1: Label = $LabelP1
@onready var label_p2: Label = $LabelP2
@onready var label_p3: Label = $LabelP3
@onready var label_p4: Label = $LabelP4

func _ready() -> void:
	# Nos conectamos a la señal del ScoreManager para recibir cambios en tiempo real
	ScoreManager.puntaje_actualizado.connect(_on_puntaje_actualizado)
	
	# Ocultamos los Labels de los jugadores opcionales 3 y 4 al inicio
	label_p3.visible = false
	label_p4.visible = false
	
	# Mostramos los puntajes iniciales de los jugadores 1 y 2
	actualizar_texto(1, ScoreManager.obtener_puntaje(1))
	actualizar_texto(2, ScoreManager.obtener_puntaje(2))

# Esta función se activa automáticamente cada vez que cambia un puntaje
func _on_puntaje_actualizado(jugador_id: int, nuevo_puntaje: int) -> void:
	actualizar_texto(jugador_id, nuevo_puntaje)

# Función para actualizar el texto y mostrar al jugador si entra a la partida
func actualizar_texto(jugador_id: int, puntaje: int) -> void:
	match jugador_id:
		1:
			label_p1.text = "P1: " + str(puntaje)
		2:
			label_p2.text = "P2: " + str(puntaje)
		3:
			label_p3.visible = true
			label_p3.text = "P3: " + str(puntaje)
		4:
			label_p4.visible = true
			label_p4.text = "P4: " + str(puntaje)
