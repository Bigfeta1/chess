extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Bishop. Slides any number of squares diagonally until a piece is in the way.
# It never changes square colour, since every diagonal step keeps the colour.

const DIRECTIONS = [
	Vector2i(1, 1),
	Vector2i(1, -1),
	Vector2i(-1, -1),
	Vector2i(-1, 1)
]

func _init() -> void:
	piece_type = PieceType.BISHOP

func get_target_squares(board_manager) -> Array:
	return get_sliding_targets(board_manager, DIRECTIONS)

# A bishop may not land on a friendly piece. Its path is always clear:
# get_sliding_targets stops at the first piece.
func can_move_to(target_square, _board_manager) -> bool:
	return target_square.is_empty() or target_square.piece.team != team
