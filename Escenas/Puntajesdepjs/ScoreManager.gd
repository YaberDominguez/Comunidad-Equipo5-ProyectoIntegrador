extends Node


# Emitimos una señal cada vez que cambia un puntaje para actualizar la pantalla automáticamente
signal puntaje_actualizado(jugador_id: int, nuevo_puntaje: int)

# Diccionario inicial solo con Jugador 1 y Jugador 2
var puntajes: Dictionary = {
	1: 0,
	2: 0
}
var jugadores_activos: int = 2

# Suma puntos a cualquier jugador
func agregar_puntos(jugador_id: int, cantidad: int) -> void:
	if puntajes.has(jugador_id):
		puntajes[jugador_id] += cantidad
		puntaje_actualizado.emit(jugador_id, puntajes[jugador_id])

# Activa a los jugadores opcionales (3 o 4)
func activar_jugador(jugador_id: int) -> void:
	if not puntajes.has(jugador_id):
		puntajes[jugador_id] = 0
		puntaje_actualizado.emit(jugador_id, 0)

# Obtener puntaje de forma segura
func obtener_puntaje(jugador_id: int) -> int:
	return puntajes.get(jugador_id, 0)

func reiniciar_puntajes() -> void:
	puntajes = {
		1: 0,
		2: 0
	}
	jugadores_activos = 2
