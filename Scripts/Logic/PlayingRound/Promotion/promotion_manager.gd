extends Node

# Pawn promotion. When a pawn lands on its last rank, the promotion is
# pending until its player picks a piece with promote(type). The pawn then
# leaves the board and its owner, and a new piece of that type takes its
# square. While a promotion is pending nothing else can be selected.

const Piece = preload("res://Scripts/Logic/PlayingRound/Pieces/piece.gd")
const PieceFactory = preload("res://Scripts/Logic/PlayingRound/Pieces/piece_factory.gd")

# Pieces a pawn can become, in the order they are offered.
const CHOICES = [
	Piece.PieceType.QUEEN,
	Piece.PieceType.ROOK,
	Piece.PieceType.BISHOP,
	Piece.PieceType.KNIGHT
]

# The pawn reached its last rank; a choice is needed.
signal promotion_started(pawn)
# The pawn was replaced by new_piece. The pawn is freed after this signal.
signal piece_promoted(pawn, new_piece)

var board_manager
var player_manager

var pending_pawn = null

func initialize(board_mngr, player_mngr, move_mngr) -> void:
	board_manager = board_mngr
	player_manager = player_mngr
	move_mngr.piece_moved.connect(_on_piece_moved)

func is_pending() -> bool:
	return pending_pawn != null

func _on_piece_moved(piece, _from_square, _to_square) -> void:
	if piece.piece_type != Piece.PieceType.PAWN or not piece.is_on_last_rank(board_manager):
		return

	pending_pawn = piece
	promotion_started.emit(piece)

# Replaces the pending pawn with a new piece of that type, on the same square
# and owned by the same player. Does nothing if no promotion is pending or
# the type is not one of CHOICES.
func promote(type: int) -> void:
	if pending_pawn == null or not CHOICES.has(type):
		return

	var pawn = pending_pawn
	pending_pawn = null

	var square = pawn.square
	var player = player_manager.get_player_by_team(pawn.team)

	board_manager.remove_piece(pawn)
	player.remove_piece(pawn)

	var new_piece = PieceFactory.create(type, pawn.team, square.square_name)
	# It arrived by moving, so it counts as moved (a promoted rook cannot castle).
	new_piece.has_moved = true
	player.add_piece(new_piece)
	board_manager.place_piece(new_piece, square.square_name)

	piece_promoted.emit(pawn, new_piece)
	pawn.queue_free()
