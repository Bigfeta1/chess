extends Node

# Holds the currently selected piece. Only pieces belonging to the player
# whose turn it is can be selected. Selection is cleared when the turn changes.
# With a piece selected, clicking one of its moves asks the move manager to move it.
# While a pawn promotion is pending, or once the game is over, clicks are ignored.

signal selection_changed(piece)

var turn_manager
var player_manager
var move_manager
var promotion_manager
var game_end_manager

var selected_piece = null

func initialize(turn_mngr, player_mngr, move_mngr, promotion_mngr, game_end_mngr) -> void:
	turn_manager = turn_mngr
	player_manager = player_mngr
	move_manager = move_mngr
	promotion_manager = promotion_mngr
	game_end_manager = game_end_mngr
	turn_manager.turn_changed.connect(_on_turn_changed)
	game_end_manager.game_ended.connect(_on_game_ended)

# Called when a square is clicked. If a piece is selected and the square is
# one of its moves, the piece moves there and the selection clears.
# Otherwise selects the piece on the square if it belongs to the current
# player; clicking the selected piece again, or anything else, clears the selection.
func select_square(square) -> void:
	if promotion_manager.is_pending() or game_end_manager.is_over():
		return

	if selected_piece != null and move_manager.move_piece(selected_piece, square):
		clear_selection()
		return

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

func _on_game_ended(_result, _winning_team) -> void:
	clear_selection()
