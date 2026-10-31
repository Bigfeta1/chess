extends Node

var board_manager = preload("res://Scenes/ConfigureRound/board_manager.tscn")

func run(configurator):
	var manager = board_manager.instantiate()
	configurator.logic.add_child(manager)
	configurator.logic.register("board_manager", manager)
