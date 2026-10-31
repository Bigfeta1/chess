extends Node

var player_manager = preload("res://Scenes/ConfigureRound/player_manager.tscn")

func run(configurator):
	var manager = player_manager.instantiate()
	configurator.logic.add_child(manager)
	configurator.logic.register("player_manager", manager)
