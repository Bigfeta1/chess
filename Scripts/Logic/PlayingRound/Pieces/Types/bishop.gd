extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Bishop. Its movement rules live here.

func _init() -> void:
	piece_type = PieceType.BISHOP

func get_moves(_board_manager) -> Array:
	return []
