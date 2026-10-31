extends Node

# Owns the 64 squares of the board (a1 to h8).
# Squares are created as children and indexed by name ("e4") for lookup.

const PlayerManager = preload("res://Scripts/Logic/PlayingRound/Players/player_manager.gd")
const Piece = preload("res://Scripts/Logic/PlayingRound/Pieces/piece.gd")

const FILES := "abcdefgh"
const BOARD_SIZE := 8

var square_script = preload("res://Scripts/Logic/PlayingRound/Board/square.gd")

var squares := {}

# The square a pawn skipped with a two-square move on the last move, or null.
# An enemy pawn may capture onto it (en passant) on the very next move only.
var en_passant_square = null

func _ready() -> void:
	build_squares()

func build_squares() -> void:
	for rank in BOARD_SIZE:
		for file in BOARD_SIZE:
			var notation = to_notation(file, rank)
			var square = Node.new()
			square.set_script(square_script)
			square.name = notation
			square.initialize(file, rank, notation)
			add_child(square)
			squares[notation] = square

func place_piece(piece, notation: String) -> void:
	var square = get_square(notation)
	if square == null or not square.is_empty():
		return

	if piece.square != null:
		piece.square.piece = null

	square.piece = piece
	piece.square = square

# Called once per finished move. Remembers the square a pawn skipped with a
# two-square move, so it can be captured en passant on the next move only.
func record_move(piece, from_square, to_square) -> void:
	en_passant_square = null
	if piece.piece_type == Piece.PieceType.PAWN and absi(to_square.rank - from_square.rank) == 2:
		en_passant_square = get_square_at(from_square.file, from_square.rank + signi(to_square.rank - from_square.rank))

# Takes a piece off the board, clearing both sides of the link.
func remove_piece(piece) -> void:
	if piece.square == null:
		return

	piece.square.piece = null
	piece.square = null

# Whether any piece of by_team on the board threatens square.
func is_threatened(square, by_team: int) -> bool:
	for other in squares.values():
		if other.is_empty() or other.piece.team != by_team:
			continue
		if other.piece.get_threatened_squares(self).has(square):
			return true
	return false

# Whether team's king is on the board and threatened by the other team.
func is_in_check(team: int) -> bool:
	var king_square = get_king_square(team)
	if king_square == null:
		return false
	return is_threatened(king_square, get_opponent(team))

# The square team's king stands on, or null if it is not on the board.
func get_king_square(team: int):
	for square in squares.values():
		if not square.is_empty() and square.piece.team == team and square.piece.piece_type == Piece.PieceType.KING:
			return square
	return null

func get_opponent(team: int) -> int:
	return PlayerManager.Team.BLACK if team == PlayerManager.Team.WHITE else PlayerManager.Team.WHITE

func get_square(notation: String):
	return squares.get(notation)

func get_square_at(file: int, rank: int):
	if not is_on_board(file, rank):
		return null
	return squares[to_notation(file, rank)]

func is_on_board(file: int, rank: int) -> bool:
	return file >= 0 and file < BOARD_SIZE and rank >= 0 and rank < BOARD_SIZE

func to_notation(file: int, rank: int) -> String:
	return FILES[file] + str(rank + 1)
