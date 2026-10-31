extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Pawn. Its movement rules live here.

func _init() -> void:
	piece_type = PieceType.PAWN

func get_moves(_board_manager) -> Array:
	return []
