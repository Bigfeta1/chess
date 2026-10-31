extends Node

# One player. Team is a PlayerManager.Team value (WHITE or BLACK).
# Owns its pieces: they are children of this node and listed in `pieces`.

signal piece_added(piece)
signal piece_removed(piece)

var player_id: String
var team: int
var is_human := true

var pieces: Array = []

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

func has_piece(piece) -> bool:
	return pieces.has(piece)

func get_pieces_of_type(type: int) -> Array:
	return pieces.filter(func(piece): return piece.piece_type == type)
