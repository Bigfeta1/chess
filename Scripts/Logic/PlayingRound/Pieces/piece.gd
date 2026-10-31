extends Node

# Base class for every chess piece. Owned by a player; sits on a board square.
# team is a PlayerManager.Team value.
# Each piece type extends this script (Pieces/Types/), sets its piece_type
# in _init, and overrides get_target_squares() and can_move_to() with its own
# movement rules.

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

# Every on-board square this piece's movement pattern reaches from where it
# stands, before validation. Overridden by each piece type.
func get_target_squares(_board_manager) -> Array:
	return []

# Whether this piece may move to a square it targets.
# Overridden by each piece type.
func can_move_to(_target_square, _board_manager) -> bool:
	return false

# Shared helper for sliding pieces (bishop, rook, queen).
# Walks from the piece's square along each direction (file step, rank step)
# and collects every square up to and including the first occupied one.
# Squares beyond a piece are not reached.
func get_sliding_targets(board_manager, directions: Array) -> Array:
	var targets := []
	if square == null:
		return targets

	for direction in directions:
		var target = board_manager.get_square_at(square.file + direction.x, square.rank + direction.y)
		while target != null:
			targets.append(target)
			if not target.is_empty():
				break
			target = board_manager.get_square_at(target.file + direction.x, target.rank + direction.y)

	return targets

# Targeted squares this piece may move to.
func get_moves(board_manager) -> Array:
	return get_target_squares(board_manager).filter(func(target): return can_move_to(target, board_manager))

# Targeted squares this piece may not move to.
func get_blocked_moves(board_manager) -> Array:
	return get_target_squares(board_manager).filter(func(target): return not can_move_to(target, board_manager))
