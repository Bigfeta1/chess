extends RefCounted

# Creates pieces of any type. Used when the board is set up and when a pawn
# is promoted.

const Piece = preload("res://Scripts/Logic/PlayingRound/Pieces/piece.gd")

# One script per piece type; each extends piece.gd.
const PIECE_SCRIPTS = {
	Piece.PieceType.KING: preload("res://Scripts/Logic/PlayingRound/Pieces/Types/king.gd"),
	Piece.PieceType.QUEEN: preload("res://Scripts/Logic/PlayingRound/Pieces/Types/queen.gd"),
	Piece.PieceType.ROOK: preload("res://Scripts/Logic/PlayingRound/Pieces/Types/rook.gd"),
	Piece.PieceType.BISHOP: preload("res://Scripts/Logic/PlayingRound/Pieces/Types/bishop.gd"),
	Piece.PieceType.KNIGHT: preload("res://Scripts/Logic/PlayingRound/Pieces/Types/knight.gd"),
	Piece.PieceType.PAWN: preload("res://Scripts/Logic/PlayingRound/Pieces/Types/pawn.gd")
}

# A new piece of that type and team, named after its type and the square it
# is created for, e.g. "Pawn_e2". It is not on the board or owned by a player yet.
static func create(type: int, team: int, notation: String):
	var piece = PIECE_SCRIPTS[type].new()
	piece.initialize(team)
	piece.name = piece.get_type_name() + "_" + notation
	return piece
