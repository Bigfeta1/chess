extends RefCounted

# Where each piece's image lives:
# Assets/Pieces/<Team>/<team>_<type>.png, e.g. Assets/Pieces/White/white_pawn.png.

const Piece = preload("res://Scripts/Logic/PlayingRound/Pieces/piece.gd")
const PlayerManager = preload("res://Scripts/Logic/PlayingRound/Players/player_manager.gd")
const SPRITE_PATH := "res://Assets/Pieces/%s/%s_%s.png"

static func get_sprite_path(team: int, type: int) -> String:
	var team_name = String(PlayerManager.Team.find_key(team)).to_lower()
	var type_name = String(Piece.PieceType.find_key(type)).to_lower()
	return SPRITE_PATH % [team_name.capitalize(), team_name, type_name]
