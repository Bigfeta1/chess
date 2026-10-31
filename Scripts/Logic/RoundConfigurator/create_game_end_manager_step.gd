extends Node

var game_end_manager = preload("res://Scenes/ConfigureRound/game_end_manager.tscn")

func run(configurator):
	var board_manager = configurator.logic.get_system("board_manager")
	var player_manager = configurator.logic.get_system("player_manager")
	var turn_manager = configurator.logic.get_system("state_manager").turn_manager
	var move_manager = configurator.logic.get_system("move_manager")
	var promotion_manager = configurator.logic.get_system("promotion_manager")

	var manager = game_end_manager.instantiate()
	configurator.logic.add_child(manager)
	configurator.logic.register("game_end_manager", manager)
	manager.initialize(board_manager, player_manager, turn_manager, move_manager, promotion_manager)
