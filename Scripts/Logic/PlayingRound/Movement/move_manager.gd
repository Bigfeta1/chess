extends Node

# Carries out moves. A move happens only if the piece's own rules allow it.

signal piece_moved(piece, from_square, to_square)

var board_manager

func initialize(board_mngr) -> void:
	board_manager = board_mngr

# Moves piece to target_square if it is one of the piece's moves.
# Returns whether the piece moved.
func move_piece(piece, target_square) -> bool:
	if piece == null or target_square == null:
		return false

	if not piece.get_moves(board_manager).has(target_square):
		return false

	# Captures are not built yet, so an occupied square cannot be entered.
	if not target_square.is_empty():
		return false

	var from_square = piece.square
	board_manager.place_piece(piece, target_square.square_name)
	piece.has_moved = true
	piece_moved.emit(piece, from_square, target_square)
	return true
