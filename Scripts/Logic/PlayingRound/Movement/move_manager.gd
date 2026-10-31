extends Node

# Carries out moves. A move happens only if the piece's own rules allow it.
# Moving onto an enemy piece captures it: it leaves the board and its owner,
# and goes to the capturing player.

signal piece_moved(piece, from_square, to_square)
# Emitted after piece_moved for the same move.
signal piece_captured(captured_piece, capturing_piece, capturing_player)

var board_manager
var player_manager

func initialize(board_mngr, player_mngr) -> void:
	board_manager = board_mngr
	player_manager = player_mngr

# Moves piece to target_square if it is one of the piece's moves.
# Returns whether the piece moved.
func move_piece(piece, target_square) -> bool:
	if piece == null or target_square == null:
		return false

	if not piece.get_moves(board_manager).has(target_square):
		return false

	var from_square = piece.square
	# Read before the piece moves: it depends on where the piece stands.
	var companion = piece.get_companion_move(target_square, board_manager)

	var captured_piece = target_square.piece
	var capturing_player = null
	if captured_piece != null:
		capturing_player = capture(piece, captured_piece)

	place(piece, target_square)

	if captured_piece != null:
		piece_captured.emit(captured_piece, piece, capturing_player)

	# A companion move (the rook when castling) follows the main one.
	if not companion.is_empty():
		place(companion.piece, companion.square)
	return true

func place(piece, target_square) -> void:
	var from_square = piece.square
	board_manager.place_piece(piece, target_square.square_name)
	piece.has_moved = true
	piece_moved.emit(piece, from_square, target_square)

# Moves captured_piece off the board and from its owner to the capturing
# piece's player. Returns that player.
func capture(capturing_piece, captured_piece):
	var capturing_player = player_manager.get_player_by_team(capturing_piece.team)
	var losing_player = player_manager.get_player_by_team(captured_piece.team)

	board_manager.remove_piece(captured_piece)
	losing_player.remove_piece(captured_piece)
	capturing_player.add_captured(captured_piece)
	return capturing_player
