extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Rook. Its movement rules live here.

func _init() -> void:
	piece_type = PieceType.ROOK

func get_moves(_board_manager) -> Array:
	return []
