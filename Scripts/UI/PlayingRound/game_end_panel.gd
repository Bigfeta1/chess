extends Control

# Shown when the game ends. Names the result and the winner, and offers a
# button back to the main menu.

const GameEndManager = preload("res://Scripts/Logic/PlayingRound/GameEnd/game_end_manager.gd")
const PlayerManager = preload("res://Scripts/Logic/PlayingRound/Players/player_manager.gd")

@onready var title = $Panel/Margin/Content/Title
@onready var detail = $Panel/Margin/Content/Detail

func initialize(game_end_manager) -> void:
	game_end_manager.game_ended.connect(_on_game_ended)
	hide()
	# The game can already be over when the round starts (a test position).
	if game_end_manager.is_over():
		_on_game_ended(game_end_manager.result, game_end_manager.winning_team)

func _on_game_ended(result, winning_team) -> void:
	if result == GameEndManager.Result.CHECKMATE:
		title.text = "CHECKMATE"
		detail.text = String(PlayerManager.Team.find_key(winning_team)).capitalize() + " wins"
	else:
		title.text = "STALEMATE"
		detail.text = "Draw"
	show()
