extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Queen. Slides any number of squares along its file, rank or diagonals
# until a piece is in the way: a rook and a bishop combined.

const DIRECTIONS = [
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
	piece_type = PieceType.QUEEN

func get_target_squares(board_manager) -> Array:
	return get_sliding_targets(board_manager, DIRECTIONS)

# A queen may not land on a friendly piece. Its path is always clear:
# get_sliding_targets stops at the first piece.
func can_move_to(target_square, _board_manager) -> bool:
	return target_square.is_empty() or target_square.piece.team != team
