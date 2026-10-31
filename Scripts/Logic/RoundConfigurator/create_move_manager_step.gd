extends Node

var move_manager = preload("res://Scenes/ConfigureRound/move_manager.tscn")

func run(configurator):
	var board_manager = configurator.logic.get_system("board_manager")
	var player_manager = configurator.logic.get_system("player_manager")

	var manager = move_manager.instantiate()
	configurator.logic.add_child(manager)
	configurator.logic.register("move_manager", manager)
	manager.initialize(board_manager, player_manager)
