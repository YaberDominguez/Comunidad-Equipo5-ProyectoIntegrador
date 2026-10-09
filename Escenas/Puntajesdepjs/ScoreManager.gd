extends Node

signal puntaje_actualizado(jugador_id: int, nuevo_puntaje: int)
signal nivel_finalizado(resultados: Dictionary)

# Bonificaciones que se entregarán RECIÉN al terminar el nivel por ser el líder
const BONO_MILANGA: int = 100
const BONO_JUGUITO: int = 50
const BONO_MONEDA: int = 30
var jugadores_activos: int = 2

var datos_jugadores: Dictionary = {
	1: { "contadores": {"Moneda": 0, "Milanga": 0, "Juguito": 0}, "puntos_base": 0 },
	2: { "contadores": {"Moneda": 0, "Milanga": 0, "Juguito": 0}, "puntos_base": 0 }
}

func activar_jugador(jugador_id: int) -> void:
	if not datos_jugadores.has(jugador_id):
		datos_jugadores[jugador_id] = {
			"contadores": {"Moneda": 0, "Milanga": 0, "Juguito": 0},
			"puntos_base": 0
		}
		puntaje_actualizado.emit(jugador_id, 0)

func agregar_item(jugador_id: int, tipo_objeto: String, cantidad_puntos: int) -> void:
	activar_jugador(jugador_id)
	
	var jugador: Dictionary = datos_jugadores[jugador_id]
	
	if jugador["contadores"].has(tipo_objeto):
		jugador["contadores"][tipo_objeto] += 1
	
	jugador["puntos_base"] += cantidad_puntos
	
	# Durante el nivel solo emitimos los puntos base para la UI
	puntaje_actualizado.emit(jugador_id, jugador["puntos_base"])

func agregar_puntos(jugador_id: int, cantidad: int) -> void:
	activar_jugador(jugador_id)
	datos_jugadores[jugador_id]["puntos_base"] += cantidad
	puntaje_actualizado.emit(jugador_id, datos_jugadores[jugador_id]["puntos_base"])

func obtener_puntaje(jugador_id: int) -> int:
	if datos_jugadores.has(jugador_id):
		return datos_jugadores[jugador_id]["puntos_base"]
	return 0

# --- LÓGICA DE FIN DE NIVEL ---

# Llamar a esta función cuando los jugadores crucen la meta o termine el tiempo
func finalizar_nivel() -> Dictionary:
	var resultados_finales: Dictionary = {}
	
	for p_id in datos_jugadores.keys():
		var puntos_base: int = datos_jugadores[p_id]["puntos_base"]
		var bono_total: int = calcular_bonificacion(p_id)
		var puntaje_final: int = puntos_base + bono_total
		
		resultados_finales[p_id] = {
			"puntos_base": puntos_base,
			"bonificacion": bono_total,
			"puntaje_total": puntaje_final,
			"contadores": datos_jugadores[p_id]["contadores"].duplicate()
		}
	
	nivel_finalizado.emit(resultados_finales)
	return resultados_finales

func calcular_bonificacion(jugador_id: int) -> int:
	var total_bono: int = 0
	
	if es_lider_de_item(jugador_id, "Milanga"):
		total_bono += BONO_MILANGA
		
	if es_lider_de_item(jugador_id, "Juguito"):
		total_bono += BONO_JUGUITO
		
	if es_lider_de_item(jugador_id, "Moneda"):
		total_bono += BONO_MONEDA
		
	return total_bono

## Comprueba si este jugador juntó estrictamente más que todos los demás rivales
func es_lider_de_item(jugador_id: int, tipo_objeto: String) -> bool:
	var mis_items: int = datos_jugadores[jugador_id]["contadores"].get(tipo_objeto, 0)
	
	# Si no agarró ninguno, no puede ganar bono
	if mis_items <= 0:
		return false
		
	for rival_id in datos_jugadores.keys():
		if rival_id != jugador_id:
			var items_rival: int = datos_jugadores[rival_id]["contadores"].get(tipo_objeto, 0)
			# Si el rival tiene igual o más cantidad, perdiste el bono (evita empates)
			if items_rival >= mis_items:
				return false
				
	return true

func reiniciar_puntajes() -> void:
	datos_jugadores = {
		1: { "contadores": {"Moneda": 0, "Milanga": 0, "Juguito": 0}, "puntos_base": 0 },
		2: { "contadores": {"Moneda": 0, "Milanga": 0, "Juguito": 0}, "puntos_base": 0 }
	}
	jugadores_activos = 2
