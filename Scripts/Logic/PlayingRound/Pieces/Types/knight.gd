extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Knight. Its movement rules live here.

func _init() -> void:
	piece_type = PieceType.KNIGHT

func get_moves(_board_manager) -> Array:
	return []
