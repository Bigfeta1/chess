extends Node

# Ends the game when the side to move has no legal moves:
# checkmate if its king is in check, stalemate (a draw) if not.
# Checked for the side to move when the manager is created, then for the
# opponent of whoever just moved, once each move is finished. If the move
# started a promotion, the check waits until the new piece is on the board.
# Once the game is over, is_over() stays true for the rest of the round.

enum Result {
	NONE,
	CHECKMATE,
	STALEMATE
}

# winning_team is a PlayerManager.Team value, or -1 for a draw.
signal game_ended(result, winning_team)

var board_manager
var player_manager
var promotion_manager

var result: Result = Result.NONE
var winning_team := -1

func initialize(board_mngr, player_mngr, turn_mngr, move_mngr, promotion_mngr) -> void:
	board_manager = board_mngr
	player_manager = player_mngr
	promotion_manager = promotion_mngr
	move_mngr.move_finished.connect(_on_move_finished)
	promotion_manager.piece_promoted.connect(_on_piece_promoted)

	var player_id = turn_mngr.get_current_player()
	if player_id != null:
		check_side(player_manager.get_player(player_id).team)

func is_over() -> bool:
	return result != Result.NONE

func _on_move_finished(piece) -> void:
	if promotion_manager.is_pending():
		return
	check_side(board_manager.get_opponent(piece.team))

func _on_piece_promoted(_pawn, new_piece) -> void:
	check_side(board_manager.get_opponent(new_piece.team))

# Ends the game if team, about to move, has no legal moves.
func check_side(team: int) -> void:
	if is_over() or has_legal_moves(team):
		return

	if board_manager.is_in_check(team):
		result = Result.CHECKMATE
		winning_team = board_manager.get_opponent(team)
	else:
		result = Result.STALEMATE
		winning_team = -1
	game_ended.emit(result, winning_team)

func has_legal_moves(team: int) -> bool:
	for piece in player_manager.get_player_by_team(team).pieces:
		if piece.square != null and not piece.get_moves(board_manager).is_empty():
			return true
	return false
