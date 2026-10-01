extends Area2D

@export var baterias_necesarias: int = 1

# Referencias a los nodos de la interfaz y gráfico
@onready var label_estado: Label = $MarcoPantalla/LabelEstado
@onready var marco_pantalla: ColorRect = $MarcoPantalla
@onready var sprite: ColorRect = $MarcoPantalla/ColorRect # Cambia a AnimatedSprite2D si usas animaciones

var baterias_en_zona: Array[Area2D] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	_limpiar_pantalla()
	call_deferred("configurar_baterias_aleatorias")


func configurar_baterias_aleatorias() -> void:
	var lista_baterias: Array = get_tree().get_nodes_in_group("Bateria")
	
	if lista_baterias.size() < 4:
		print("ADVERTENCIA: Se necesitan al menos 4 baterías en el nivel para barajar.")
		return

	lista_baterias.shuffle()

	if lista_baterias[0].has_method("establecer_estado"):
		lista_baterias[0].establecer_estado(true)
	else:
		lista_baterias[0].funciona = true

	for i in range(1, lista_baterias.size()):
		if lista_baterias[i].has_method("establecer_estado"):
			lista_baterias[i].establecer_estado(false)
		else:
			lista_baterias[i].funciona = false

	print("🎮 Baterías barajadas automáticamente: 1 funcional y 3 defectuosas.")


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Bateria"):
		if not baterias_en_zona.has(area):
			baterias_en_zona.append(area)
			_evaluar_terminal()


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Bateria"):
		if baterias_en_zona.has(area):
			baterias_en_zona.erase(area)
			_limpiar_pantalla()
			_evaluar_terminal()


func _evaluar_terminal() -> void:
	if baterias_en_zona.size() < baterias_necesarias:
		print("Terminal: Hay ", baterias_en_zona.size(), " de ", baterias_necesarias, " baterías.")
		return

	var todas_bien: bool = true

	for bateria in baterias_en_zona:
		if "funciona" in bateria and bateria.funciona == false:
			todas_bien = false
			break

	if todas_bien:
		_al_activar_exito()
	else:
		_al_activar_fallo()


func _al_activar_exito() -> void:
	print("✅ ¡ÉXITO! Batería funcional detectada.")
	
	# 1. Texto y color del Label
	if label_estado:
		label_estado.text = "¡FUNCIONAL!"
		label_estado.modulate = Color.GREEN
		
	# 2. Tono/Luz verde en el Sprite
	if sprite:
		sprite.modulate = Color(0.7, 1.0, 0.7)
		# Si usas hojas de sprites con frames:
		# sprite.frame = 1 


func _al_activar_fallo() -> void:
	print("❌ FALLO: Batería defectuosa.")
	
	# 1. Texto y color del Label
	if label_estado:
		label_estado.text = "DEFECTUOSA"
		label_estado.modulate = Color.RED
		
	# 2. Tono/Luz roja en el Sprite
	if sprite:
		sprite.modulate = Color(0.641, 0.0, 0.165, 1.0)
		# Si usas hojas de sprites con frames:
		# sprite.frame = 2


func _limpiar_pantalla() -> void:
	if label_estado:
		label_estado.text = "ESPERANDO..."
		label_estado.modulate = Color.GRAY
		
	if sprite:
		sprite.modulate = Color.WHITE # Vuelve al color base del sprite
		# If usas frames:
		# sprite.frame = 0
