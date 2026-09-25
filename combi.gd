extends Area2D
var todos_en_el_area:= false
func _ready() -> void:
	add_to_group("Combi")
	body_entered.connect(siguiente_nivel)
func siguiente_nivel(body: CharacterBody2D):
	pass
