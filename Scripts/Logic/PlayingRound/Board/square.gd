extends Node

# One square of the board. Holds its coordinates, colour and occupant.
# file: 0-7 for a-h. rank: 0-7 for 1-8.

var file: int
var rank: int
var square_name: String
var is_light: bool
var piece = null

func initialize(file_index: int, rank_index: int, notation: String) -> void:
	file = file_index
	rank = rank_index
	square_name = notation
	# a1 is dark: a square is light when file + rank is odd.
	is_light = (file + rank) % 2 == 1

func is_empty() -> bool:
	return piece == null
