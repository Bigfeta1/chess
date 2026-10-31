extends Node

# Holds the currently selected piece. Only pieces belonging to the player
# whose turn it is can be selected. Selection is cleared when the turn changes.

signal selection_changed(piece)

var turn_manager
var player_manager

var selected_piece = null

func initialize(turn_mngr, player_mngr) -> void:
	turn_manager = turn_mngr
	player_manager = player_mngr
	turn_manager.turn_changed.connect(_on_turn_changed)

# Called when a square is clicked. Selects the piece on it if it belongs to
# the current player; clicking the selected piece again, or anything else,
# clears the selection.
func select_square(square) -> void:
	if square == null or square.is_empty():
		clear_selection()
		return

	var piece = square.piece

	if piece == selected_piece or not can_select(piece):
		clear_selection()
		return

	selected_piece = piece
	selection_changed.emit(selected_piece)

func can_select(piece) -> bool:
	var current_player = get_current_player()
	return current_player != null and piece.team == current_player.team

func get_current_player():
	var player_id = turn_manager.get_current_player()
	if player_id == null:
		return null
	return player_manager.get_player(player_id)

func clear_selection() -> void:
	if selected_piece == null:
		return

	selected_piece = null
	selection_changed.emit(null)

func _on_turn_changed(_new_turn) -> void:
	clear_selection()
