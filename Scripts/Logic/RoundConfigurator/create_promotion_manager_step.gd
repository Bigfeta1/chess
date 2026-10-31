extends Node

var promotion_manager = preload("res://Scenes/ConfigureRound/promotion_manager.tscn")

func run(configurator):
	var board_manager = configurator.logic.get_system("board_manager")
	var player_manager = configurator.logic.get_system("player_manager")
	var move_manager = configurator.logic.get_system("move_manager")

	var manager = promotion_manager.instantiate()
	configurator.logic.add_child(manager)
	configurator.logic.register("promotion_manager", manager)
	manager.initialize(board_manager, player_manager, move_manager)
