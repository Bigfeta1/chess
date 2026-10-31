extends Node

# One player. Team is a PlayerManager.Team value (WHITE or BLACK).
# Owns its pieces: they are children of this node and listed in `pieces`.
# Also owns the enemy pieces it has captured, listed in `captured_pieces`
# (also children of this node). They are kept grouped by type in CAPTURE_ORDER.

const Piece = preload("res://Scripts/Logic/PlayingRound/Pieces/piece.gd")

# Order captured pieces are grouped in. A type not listed goes last.
const CAPTURE_ORDER = [
	Piece.PieceType.PAWN,
	Piece.PieceType.KNIGHT,
	Piece.PieceType.BISHOP,
	Piece.PieceType.ROOK,
	Piece.PieceType.QUEEN
]

signal piece_added(piece)
signal piece_removed(piece)
signal piece_captured(piece)

var player_id: String
var team: int
var is_human := true

var pieces: Array = []
var captured_pieces: Array = []

func initialize(id: String, player_team: int) -> void:
	player_id = id
	team = player_team

func add_piece(piece) -> void:
	if pieces.has(piece):
		return

	pieces.append(piece)
	add_child(piece)
	piece_added.emit(piece)

func remove_piece(piece) -> void:
	if not pieces.has(piece):
		return

	pieces.erase(piece)
	remove_child(piece)
	piece_removed.emit(piece)

# Takes ownership of an enemy piece this player captured. It goes after the
# last captured piece of the same group, so each type stays together.
func add_captured(piece) -> void:
	if captured_pieces.has(piece):
		return

	var rank = get_capture_rank(piece)
	var index = captured_pieces.size()
	for i in captured_pieces.size():
		if get_capture_rank(captured_pieces[i]) > rank:
			index = i
			break

	captured_pieces.insert(index, piece)
	add_child(piece)
	piece_captured.emit(piece)

func get_capture_rank(piece) -> int:
	var rank = CAPTURE_ORDER.find(piece.piece_type)
	return CAPTURE_ORDER.size() if rank == -1 else rank

# Every square threatened by at least one of this player's pieces on the board.
func get_threatened_squares(board_manager) -> Array:
	var threatened := []
	for piece in pieces:
		for target in piece.get_threatened_squares(board_manager):
			if not threatened.has(target):
				threatened.append(target)
	return threatened

func has_piece(piece) -> bool:
	return pieces.has(piece)

func get_pieces_of_type(type: int) -> Array:
	return pieces.filter(func(piece): return piece.piece_type == type)
