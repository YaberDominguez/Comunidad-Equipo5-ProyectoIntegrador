extends Control

# Asegúrate de que la ruta coincida con la escena del Paso 1
const PLAYER_CARD_SCENE = preload("res://player_card.tscn")

@onready var players_container: HBoxContainer = $PlayersContainer

var player_scores: Dictionary = {}
var player_cards: Dictionary = {}

var player_colors: Array[Color] = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.YELLOW
]

# Inicializa el marcador según cuántos jueguen (2, 3 o 4)
# En Scoreboard.gd

func setup_scoreboard(total_players: int) -> void:
	# Aseguramos que players_container esté listo antes de usarlo
	if not players_container:
		players_container = $PlayersContainer
		
	total_players = clampi(total_players, 2, 4)
	
	for child in players_container.get_children():
		child.queue_free()
		
	player_scores.clear()
	player_cards.clear()
	
	for i in range(1, total_players + 1):
		player_scores[i] = 0
		var card = PLAYER_CARD_SCENE.instantiate()
		players_container.add_child(card)
		card.setup(i, player_colors[i - 1])
		player_cards[i] = card

# Llama a esta función para sumar puntos
func add_score(player_id: int, points: int) -> void:
	if player_scores.has(player_id):
		player_scores[player_id] += points
		player_cards[player_id].update_score(player_scores[player_id])
