extends RigidBody2D

@onready var squeak_audio: AudioStreamPlayer2D = $SqueakAudio

# Velocidad mínima requerida para activar el sonido
@export var min_speed_to_squeak: float = 10.0

func _physics_process(_delta: float) -> void:
	# Calculamos qué tan rápido se está moviendo el objeto
	var current_speed = linear_velocity.length()
	
	# Si la velocidad supera el umbral, reproducimos el sonido
	if current_speed > min_speed_to_squeak:
		if not squeak_audio.playing:
			squeak_audio.play()
	else:
		if squeak_audio.playing:
			squeak_audio.stop()
