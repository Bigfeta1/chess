extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Knight. Jumps in an L: two squares one way, one square the other.
# Pieces in between do not block it.

const OFFSETS = [
	Vector2i(1, 2),
	Vector2i(2, 1),
	Vector2i(2, -1),
	Vector2i(1, -2),
	Vector2i(-1, -2),
	Vector2i(-2, -1),
	Vector2i(-2, 1),
	Vector2i(-1, 2)
]

func _init() -> void:
	piece_type = PieceType.KNIGHT

func get_target_squares(board_manager) -> Array:
	var targets := []
	if square == null:
		return targets

	for offset in OFFSETS:
		var target = board_manager.get_square_at(square.file + offset.x, square.rank + offset.y)
		if target != null:
			targets.append(target)

	return targets

# A knight may not land on a friendly piece.
func can_move_to(target_square, _board_manager) -> bool:
	return target_square.is_empty() or target_square.piece.team != team
