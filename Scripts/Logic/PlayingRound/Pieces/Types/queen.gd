extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Queen. Its movement rules live here.

func _init() -> void:
	piece_type = PieceType.QUEEN

func get_moves(_board_manager) -> Array:
	return []
