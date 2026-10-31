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

# Squares this piece threatens: where it would capture an enemy piece.
# Empty squares count, as do squares holding an enemy; squares behind a
# piece and squares holding a friendly piece do not. For most pieces this
# is the same as their pattern moves; pawns and kings override it.
# A piece threatens a square even if moving there would expose its own king
# (a pinned piece still gives check), so this uses get_pattern_moves().
func get_threatened_squares(board_manager) -> Array:
	return get_pattern_moves(board_manager)

# A second piece that moves as part of moving this piece to target_square,
# as { "piece": ..., "square": ... }, or an empty dictionary for none.
# Only the king uses this, for the rook when castling.
func get_companion_move(_target_square, _board_manager) -> Dictionary:
	return {}

# The piece captured by moving to target_square, or null. Usually whatever
# stands on the target; the pawn overrides it for en passant.
func get_captured_piece(target_square, _board_manager):
	return target_square.piece

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

# Targeted squares this piece's own rules allow, ignoring check.
func get_pattern_moves(board_manager) -> Array:
	return get_target_squares(board_manager).filter(func(target): return can_move_to(target, board_manager))

# Targeted squares this piece may move to: its own rules allow it and the
# move does not leave its king threatened.
func get_moves(board_manager) -> Array:
	return get_pattern_moves(board_manager).filter(func(target): return not leaves_king_in_check(target, board_manager))

# Targeted squares this piece may not move to.
func get_blocked_moves(board_manager) -> Array:
	var moves = get_moves(board_manager)
	return get_target_squares(board_manager).filter(func(target): return not moves.has(target))

# Whether this piece's king would be threatened after it moved to
# target_square. The move is tried directly on the square links and undone;
# no signals are emitted. The captured piece (get_captured_piece) is taken
# off its square while the move is tried; for en passant that is not the
# target square.
# For castling only the king is tried; can_castle already checks every
# square the king stands on, crosses or lands on.
func leaves_king_in_check(target_square, board_manager) -> bool:
	var from_square = square
	var captured = get_captured_piece(target_square, board_manager)
	var captured_square = null

	if captured != null:
		captured_square = captured.square
		captured_square.piece = null
		captured.square = null
	from_square.piece = null
	target_square.piece = self
	square = target_square

	var in_check = board_manager.is_in_check(team)

	square = from_square
	target_square.piece = null
	from_square.piece = self
	if captured != null:
		captured_square.piece = captured
		captured.square = captured_square

	return in_check
