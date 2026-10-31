extends Node

# Owns the two players. Players are created as children and indexed by id.

enum Team {
	WHITE,
	BLACK
}

var player_script = preload("res://Scripts/Logic/PlayingRound/Players/player.gd")

var players := {}

func _ready() -> void:
	create_player("white", Team.WHITE)
	create_player("black", Team.BLACK)

func create_player(id: String, team: Team) -> void:
	var player = Node.new()
	player.set_script(player_script)
	player.name = id.capitalize()
	player.initialize(id, team)
	add_child(player)
	players[id] = player

func get_player(id: String):
	return players.get(id)

func get_player_by_team(team: Team):
	for player in players.values():
		if player.team == team:
			return player
	return null

# Players in move order: white first.
func get_player_ids() -> Array:
	return [get_player_by_team(Team.WHITE).player_id, get_player_by_team(Team.BLACK).player_id]
