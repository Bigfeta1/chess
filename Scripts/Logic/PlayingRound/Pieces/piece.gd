extends Node

# Base class for every chess piece. Owned by a player; sits on a board square.
# team is a PlayerManager.Team value.
# Each piece type extends this script (Pieces/Types/) and sets its piece_type
# in _init, and overrides get_moves() with its own movement rules.

enum PieceType {
	KING,
	QUEEN,
	ROOK,
	BISHOP,
	KNIGHT,
	PAWN
}

var piece_type: PieceType
var team: int
var square = null
var has_moved := false

func initialize(piece_team: int) -> void:
	team = piece_team

func get_type_name() -> String:
	return PieceType.find_key(piece_type).capitalize()

# Squares this piece could move to from where it stands.
# Overridden by each piece type.
func get_moves(_board_manager) -> Array:
	return []
