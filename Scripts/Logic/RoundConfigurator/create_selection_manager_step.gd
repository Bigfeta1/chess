extends Node

var selection_manager = preload("res://Scenes/ConfigureRound/selection_manager.tscn")

func run(configurator):
	var turn_manager = configurator.logic.get_system("state_manager").turn_manager
	var player_manager = configurator.logic.get_system("player_manager")
	var move_manager = configurator.logic.get_system("move_manager")
	var promotion_manager = configurator.logic.get_system("promotion_manager")
	var game_end_manager = configurator.logic.get_system("game_end_manager")

	var manager = selection_manager.instantiate()
	configurator.logic.add_child(manager)
	configurator.logic.register("selection_manager", manager)
	manager.initialize(turn_manager, player_manager, move_manager, promotion_manager, game_end_manager)
