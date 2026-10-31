extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# King. Steps one square in any direction, or castles.
# Check is not built yet: the king can still step onto a threatened square
# with a normal move.
#
# Castling moves the king two squares toward a rook, and the rook to the
# square the king crossed. It is a target while the king and that rook have
# never moved and none of the king's own pieces stand between them.
# It is allowed only if:
#   - every square between the king and the rook is empty, and
#   - no opponent piece threatens the king's square, the square it crosses,
#     or the square it lands on.
# Queenside the rook's neighbour (the b-file) must be empty but may be
# threatened, since the king never crosses it.

const PlayerManager = preload("res://Scripts/Logic/PlayingRound/Players/player_manager.gd")

const OFFSETS = [
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1)
]

# Files (0 = a) for each side's castling.
const CASTLING = {
	"kingside": { "rook_file": 7, "king_to": 6, "rook_to": 5 },
	"queenside": { "rook_file": 0, "king_to": 2, "rook_to": 3 }
}

func _init() -> void:
	piece_type = PieceType.KING

func get_target_squares(board_manager) -> Array:
	var targets := get_step_squares(board_manager)
	for side in CASTLING:
		if get_castling_rook(side, board_manager) != null and not has_friendly_between(side, board_manager):
			targets.append(board_manager.get_square_at(CASTLING[side].king_to, square.rank))
	return targets

# Whether any of this king's own pieces stand between it and that side's rook.
func has_friendly_between(side: String, board_manager) -> bool:
	for between in get_squares_between(side, board_manager):
		if not between.is_empty() and between.piece.team == team:
			return true
	return false

# The squares between the king and that side's corner.
func get_squares_between(side: String, board_manager) -> Array:
	var between := []
	var rook_file = CASTLING[side].rook_file
	var step = signi(rook_file - square.file)
	var file = square.file + step
	while file != rook_file:
		between.append(board_manager.get_square_at(file, square.rank))
		file += step
	return between

# The eight neighbouring squares on the board.
func get_step_squares(board_manager) -> Array:
	var targets := []
	if square == null:
		return targets

	for offset in OFFSETS:
		var target = board_manager.get_square_at(square.file + offset.x, square.rank + offset.y)
		if target != null:
			targets.append(target)

	return targets

func can_move_to(target_square, board_manager) -> bool:
	var side = get_castling_side(target_square)
	if side != "":
		return can_castle(side, board_manager)

	# A king may not land on a friendly piece.
	return target_square.is_empty() or target_square.piece.team != team

# A king threatens only its neighbours: castling never captures. This also
# stops two kings from asking each other about castling forever.
func get_threatened_squares(board_manager) -> Array:
	return get_step_squares(board_manager).filter(func(target): return target.is_empty() or target.piece.team != team)

# Castling moves the rook too.
func get_companion_move(target_square, board_manager) -> Dictionary:
	var side = get_castling_side(target_square)
	if side == "":
		return {}

	return {
		"piece": get_castling_rook(side, board_manager),
		"square": board_manager.get_square_at(CASTLING[side].rook_to, square.rank)
	}

# "kingside" or "queenside" if moving to target_square would castle, else "".
func get_castling_side(target_square) -> String:
	if square == null or target_square.rank != square.rank:
		return ""

	for side in CASTLING:
		if target_square.file == CASTLING[side].king_to and absi(target_square.file - square.file) == 2:
			return side
	return ""

# The rook this king could castle with on that side, or null if the king
# or the rook has moved, or the corner holds no friendly rook.
func get_castling_rook(side: String, board_manager):
	if square == null or has_moved:
		return null

	var corner = board_manager.get_square_at(CASTLING[side].rook_file, square.rank)
	if corner == null or corner.is_empty():
		return null

	var rook = corner.piece
	if rook.team != team or rook.piece_type != PieceType.ROOK or rook.has_moved:
		return null
	return rook

func can_castle(side: String, board_manager) -> bool:
	if get_castling_rook(side, board_manager) == null:
		return false

	var king_to = CASTLING[side].king_to
	var step = signi(CASTLING[side].rook_file - square.file)

	# Every square between the king and the rook must be empty.
	for between in get_squares_between(side, board_manager):
		if not between.is_empty():
			return false

	# The king's square, the square it crosses and where it lands must not
	# be threatened.
	var opponent = PlayerManager.Team.BLACK if team == PlayerManager.Team.WHITE else PlayerManager.Team.WHITE
	var file = square.file
	while true:
		if board_manager.is_threatened(board_manager.get_square_at(file, square.rank), opponent):
			return false
		if file == king_to:
			break
		file += step

	return true
