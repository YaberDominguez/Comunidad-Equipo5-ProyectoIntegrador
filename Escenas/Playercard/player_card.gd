extends VBoxContainer

@onready var name_label: Label = $NameLabel
@onready var score_label: Label = $ScoreLabel

func setup(player_id: int, color: Color) -> void:
	# Aseguramos que las referencias a los Labels existan antes de asignar el texto
	if not name_label:
		name_label = $NameLabel
	if not score_label:
		score_label = $ScoreLabel
		
	name_label.text = "Jugador " + str(player_id)
	name_label.modulate = color

func update_score(points: int) -> void:
	if not score_label:
		score_label = $ScoreLabel
		
	score_label.text = str(points)
