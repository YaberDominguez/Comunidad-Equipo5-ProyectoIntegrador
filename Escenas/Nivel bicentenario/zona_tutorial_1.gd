extends Area2D

# Arrastra el nodo TutorialUI desde tu árbol de escenas hacia el script 
# manteniendo presionada la tecla Ctrl, o búscalo con la ruta correcta:
@onready var cartel_tutorial =  # Ajusta la ruta si es necesario

func _on_body_entered(body):
	# Usamos el grupo "jugadores" que creamos en el paso de la cámara
	if body.is_in_group("jugadores"):
		cartel_tutorial.show()

func _on_body_exited(body):
	if body.is_in_group("jugadores"):
		# Opcional: Podrías contar cuántos jugadores hay en el área para no 
		# ocultarlo si sale el Jugador 1 pero el Jugador 2 sigue adentro.
		cartel_tutorial.hide()
