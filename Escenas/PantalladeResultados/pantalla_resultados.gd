extends Control

@onready var label_puntaje_final: Label = $LabelPuntajes
@onready var boton_reiniciar: Button = $Botonera/Btnreset
@onready var boton_menu: Button = $Botonera/Btnmenu


func _ready() -> void:
	boton_reiniciar.pressed.connect(_on_boton_reiniciar_pressed)
	boton_menu.pressed.connect(_on_boton_menu_pressed)
	
	# Hace que el primer botón reciba el foco para Gamepad / Teclado
	boton_reiniciar.grab_focus()
	
	actualizar_texto_puntajes()


func actualizar_texto_puntajes() -> void:
	# 1. Calculamos y obtenemos el desglose final (con bonos) desde ScoreManager
	var resultados: Dictionary = ScoreManager.finalizar_nivel()
	
	var texto: String = "PUNTAJES FINALES\n\n"
	
	# 2. Creamos la lista de jugadores ordenables
	var lista_jugadores: Array = []
	
	for p_id in resultados.keys():
		lista_jugadores.append({
			"id": p_id,
			"puntos_base": resultados[p_id]["puntos_base"],
			"bonificacion": resultados[p_id]["bonificacion"],
			"puntaje_total": resultados[p_id]["puntaje_total"]
		})
	
	# 3. Ordenamos de MAYOR a MENOR por el puntaje total (base + bono)
	lista_jugadores.sort_custom(func(a, b): return a["puntaje_total"] > b["puntaje_total"])
	
	# 4. Construimos el texto mostrando el desglose
	for posicion in range(lista_jugadores.size()):
		var jugador = lista_jugadores[posicion]
		var id_jugador: int = jugador["id"]
		var pts_base: int = jugador["puntos_base"]
		var bono: int = jugador["bonificacion"]
		var total: int = jugador["puntaje_total"]
		
		var linea: String = ""
		
		# Distinción para el ganador
		if posicion == 0:
			linea += "👑 1° - Jugador " + str(id_jugador) + ": " + str(total) + " pts"
		else:
			linea += str(posicion + 1) + "° - Jugador " + str(id_jugador) + ": " + str(total) + " pts"
		
		# Si obtuvo alguna bonificación de líder, mostramos el detalle entre paréntesis
		if bono > 0:
			linea += " (Base: " + str(pts_base) + " + Bono: " + str(bono) + ")"
		
		texto += linea + "\n"
		
	label_puntaje_final.text = texto


func _on_boton_reiniciar_pressed() -> void:
	ScoreManager.reiniciar_puntajes()
	get_tree().change_scene_to_file("res://Escenas/Nivel bicentenario/Nivel_bicenterario.tscn")


func _on_boton_menu_pressed() -> void:
	ScoreManager.reiniciar_puntajes()
	get_tree().change_scene_to_file("res://Escenas/Menu principal/menu_principal.tscn")
