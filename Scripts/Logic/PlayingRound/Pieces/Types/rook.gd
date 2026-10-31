extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Rook. Slides any number of squares along its file or rank until a piece
# is in the way.

const DIRECTIONS = [
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0)
]

func _init() -> void:
	piece_type = PieceType.ROOK

func get_target_squares(board_manager) -> Array:
	return get_sliding_targets(board_manager, DIRECTIONS)

# A rook may not land on a friendly piece. Its path is always clear:
# get_sliding_targets stops at the first piece.
func can_move_to(target_square, _board_manager) -> bool:
	return target_square.is_empty() or target_square.piece.team != team
