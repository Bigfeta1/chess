extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# King. Steps one square in any direction.
# Castling and check are not built yet.

const OFFSETS = [
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1)
]

func _init() -> void:
	piece_type = PieceType.KING

func get_target_squares(board_manager) -> Array:
	var targets := []
	if square == null:
		return targets

	for offset in OFFSETS:
		var target = board_manager.get_square_at(square.file + offset.x, square.rank + offset.y)
		if target != null:
			targets.append(target)

	return targets

# A king may not land on a friendly piece.
func can_move_to(target_square, _board_manager) -> bool:
	return target_square.is_empty() or target_square.piece.team != team
