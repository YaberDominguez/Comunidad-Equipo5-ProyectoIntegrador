extends Control
func _ready() -> void:
	$Botonera/btnJugar.pressed.connect(vamo_a_jugar)
	$Botonera/btnSalir.pressed.connect(hasta_la_proxima)
	$Botonera/btnCreditos.pressed.connect(Creditos)

func vamo_a_jugar() -> void:
	get_tree().change_scene_to_file("res://Escenas/Nivel bicentenario/Nivel_bicenterario.tscn")
func hasta_la_proxima() -> void:
	get_tree().quit()
func Creditos() -> void:
	get_tree().change_scene_to_file("res://Escenas/Creditos/creditos.tscn")
