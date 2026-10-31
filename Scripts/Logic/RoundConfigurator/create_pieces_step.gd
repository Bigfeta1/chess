extends Node

# Creates the 32 starting pieces, gives each to its player,
# and places it on its starting square.

const Piece = preload("res://Scripts/Logic/PlayingRound/Pieces/piece.gd")
const PlayerManager = preload("res://Scripts/Logic/PlayingRound/Players/player_manager.gd")
const PieceFactory = preload("res://Scripts/Logic/PlayingRound/Pieces/piece_factory.gd")

const BACK_RANK = [
	Piece.PieceType.ROOK,
	Piece.PieceType.KNIGHT,
	Piece.PieceType.BISHOP,
	Piece.PieceType.QUEEN,
	Piece.PieceType.KING,
	Piece.PieceType.BISHOP,
	Piece.PieceType.KNIGHT,
	Piece.PieceType.ROOK
]

# Rank indices (0 = rank 1): back rank, then pawn rank.
const START_RANKS = {
	PlayerManager.Team.WHITE: [0, 1],
	PlayerManager.Team.BLACK: [7, 6]
}

func run(configurator):
	var board_manager = configurator.logic.get_system("board_manager")
	var player_manager = configurator.logic.get_system("player_manager")

	for team in START_RANKS:
		var player = player_manager.get_player_by_team(team)
		var back_rank = START_RANKS[team][0]
		var pawn_rank = START_RANKS[team][1]

		for file in board_manager.BOARD_SIZE:
			create_piece(BACK_RANK[file], player, board_manager, board_manager.to_notation(file, back_rank))
			create_piece(Piece.PieceType.PAWN, player, board_manager, board_manager.to_notation(file, pawn_rank))

func create_piece(type, player, board_manager, notation: String) -> void:
	var piece = PieceFactory.create(type, player.team, notation)
	player.add_piece(piece)
	board_manager.place_piece(piece, notation)
