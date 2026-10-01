extends Control

@onready var label_puntaje_final: Label = $LabelPuntajes
@onready var boton_reiniciar: Button = $Botonera/Btnreset
@onready var boton_menu: Button = $Botonera/Btnmenu


func _ready() -> void:
	boton_reiniciar.pressed.connect(_on_boton_reiniciar_pressed)
	boton_menu.pressed.connect(_on_boton_menu_pressed)
	
	# Hace que el primer botón reciba el foco para poder usar Gamepad o Teclado
	boton_reiniciar.grab_focus()
	
	actualizar_texto_puntajes()


func actualizar_texto_puntajes() -> void:
	var texto: String = "PUNTAJES\n\n"
	
	# Leemos los puntos usando la función obtener_puntaje() de tu ScoreManager
	texto += "Jugador 1: " + str(ScoreManager.obtener_puntaje(1)) + " pts\n"
	texto += "Jugador 2: " + str(ScoreManager.obtener_puntaje(2)) + " pts\n"
	
	if ScoreManager.jugadores_activos >= 3:
		texto += "Jugador 3: " + str(ScoreManager.obtener_puntaje(3)) + " pts\n"
	if ScoreManager.jugadores_activos >= 4:
		texto += "Jugador 4: " + str(ScoreManager.obtener_puntaje(4)) + " pts\n"
		
	label_puntaje_final.text = texto


func _on_boton_reiniciar_pressed() -> void:
	ScoreManager.reiniciar_puntajes()
	# Pon aquí la ruta de tu nivel
	get_tree().change_scene_to_file("res://Escenas/Nivel bicentenario/Nivel_bicenterario.tscn")


func _on_boton_menu_pressed() -> void:
	ScoreManager.reiniciar_puntajes()
	# Pon aquí la ruta de tu menú principal
	get_tree().change_scene_to_file("res://Escenas/Menu principal/menu_principal.tscn")
