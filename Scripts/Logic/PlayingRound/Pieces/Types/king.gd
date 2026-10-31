extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# King. Its movement rules live here.

func _init() -> void:
	piece_type = PieceType.KING

func get_moves(_board_manager) -> Array:
	return []
