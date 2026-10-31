extends "res://Scripts/Logic/PlayingRound/Pieces/piece.gd"

# Pawn. Moves straight forward one square, or two on its first move.
# Forward is up the board (toward rank 8) for white, down it for black.
# It cannot move onto or through any piece going straight.
# It captures one square diagonally forward, and only moves diagonally
# when capturing.
#
# En passant: if an enemy pawn moves two squares and lands right beside this
# pawn while this pawn stands on its fifth rank (rank 5 for white, rank 4
# for black), this pawn may capture it on the very next move by moving
# diagonally onto the square the enemy pawn skipped. The enemy pawn is
# removed from beside it.

const PlayerManager = preload("res://Scripts/Logic/PlayingRound/Players/player_manager.gd")

func _init() -> void:
	piece_type = PieceType.PAWN

# Rank step for one square forward: +1 for white, -1 for black.
func get_forward() -> int:
	return 1 if team == PlayerManager.Team.WHITE else -1

# Rank index the pawn promotes on: 7 (rank 8) for white, 0 (rank 1) for black.
func get_last_rank(board_manager) -> int:
	return board_manager.BOARD_SIZE - 1 if team == PlayerManager.Team.WHITE else 0

# Whether the pawn stands on its last rank and must be promoted.
func is_on_last_rank(board_manager) -> bool:
	return square != null and square.rank == get_last_rank(board_manager)

# Rank index the pawn must stand on to capture en passant, its fifth rank:
# 4 (rank 5) for white, 3 (rank 4) for black.
func get_en_passant_rank(board_manager) -> int:
	return 4 if team == PlayerManager.Team.WHITE else board_manager.BOARD_SIZE - 1 - 4

# The enemy pawn this pawn would capture en passant by moving to
# target_square, or null if that move is not an en passant capture.
# target_square must be the square an enemy pawn skipped on the last move,
# diagonally forward of this pawn standing on its fifth rank, with that
# enemy pawn right beside this one.
func get_en_passant_victim(target_square, board_manager):
	if square == null or target_square == null or target_square != board_manager.en_passant_square:
		return null
	if square.rank != get_en_passant_rank(board_manager):
		return null
	if absi(target_square.file - square.file) != 1 or target_square.rank != square.rank + get_forward():
		return null

	var beside = board_manager.get_square_at(target_square.file, square.rank)
	if beside.is_empty():
		return null
	var victim = beside.piece
	if victim.team == team or victim.piece_type != PieceType.PAWN:
		return null
	return victim

# En passant captures the pawn beside the target, not a piece on it.
func get_captured_piece(target_square, board_manager):
	var victim = get_en_passant_victim(target_square, board_manager)
	if victim != null:
		return victim
	return target_square.piece

# One square forward, plus two squares forward if the pawn has not moved yet,
# plus each diagonal-forward square that holds an enemy piece or can be
# captured onto en passant.
func get_target_squares(board_manager) -> Array:
	var targets := []
	if square == null:
		return targets

	var max_steps = 1 if has_moved else 2
	for steps in range(1, max_steps + 1):
		var target = board_manager.get_square_at(square.file, square.rank + get_forward() * steps)
		if target != null:
			targets.append(target)

	for side in [-1, 1]:
		var diagonal = board_manager.get_square_at(square.file + side, square.rank + get_forward())
		if diagonal == null:
			continue
		if (not diagonal.is_empty() and diagonal.piece.team != team) or get_en_passant_victim(diagonal, board_manager) != null:
			targets.append(diagonal)

	return targets

# A pawn threatens both diagonal-forward squares, empty or not, but never
# the squares straight ahead, since it cannot capture there.
func get_threatened_squares(board_manager) -> Array:
	var threats := []
	if square == null:
		return threats

	for side in [-1, 1]:
		var diagonal = board_manager.get_square_at(square.file + side, square.rank + get_forward())
		if diagonal != null and (diagonal.is_empty() or diagonal.piece.team != team):
			threats.append(diagonal)

	return threats

# Diagonally: only onto an enemy piece, or en passant.
# Straight: the target and every square between it and the pawn must be empty.
func can_move_to(target_square, board_manager) -> bool:
	if target_square.file != square.file:
		if get_en_passant_victim(target_square, board_manager) != null:
			return true
		return not target_square.is_empty() and target_square.piece.team != team

	var steps = absi(target_square.rank - square.rank)
	for step in range(1, steps + 1):
		var on_path = board_manager.get_square_at(square.file, square.rank + get_forward() * step)
		if not on_path.is_empty():
			return false
	return true
