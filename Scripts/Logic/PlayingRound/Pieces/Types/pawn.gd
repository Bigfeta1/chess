extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Pawn. Moves straight forward one square, or two on its first move.
# Forward is up the board (toward rank 8) for white, down it for black.
# It cannot move onto or through any piece.
# Diagonal captures are not built yet.

const PlayerManager = preload("res://Scripts/Logic/PlayingRound/Players/player_manager.gd")

func _init() -> void:
	piece_type = PieceType.PAWN

# Rank step for one square forward: +1 for white, -1 for black.
func get_forward() -> int:
	return 1 if team == PlayerManager.Team.WHITE else -1

# One square forward, plus two squares forward if the pawn has not moved yet.
func get_target_squares(board_manager) -> Array:
	var targets := []
	if square == null:
		return targets

	var max_steps = 1 if has_moved else 2
	for steps in range(1, max_steps + 1):
		var target = board_manager.get_square_at(square.file, square.rank + get_forward() * steps)
		if target != null:
			targets.append(target)

	return targets

# The target and every square between it and the pawn must be empty.
func can_move_to(target_square, board_manager) -> bool:
	var steps = absi(target_square.rank - square.rank)
	for step in range(1, steps + 1):
		var on_path = board_manager.get_square_at(square.file, square.rank + get_forward() * step)
		if not on_path.is_empty():
			return false
	return true
