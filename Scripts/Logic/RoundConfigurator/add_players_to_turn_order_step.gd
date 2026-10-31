extends Node

# Puts the players into the turn order and starts the first turn (white).

func run(configurator):
	var player_manager = configurator.logic.get_system("player_manager")
	var turn_manager = configurator.logic.get_system("state_manager").turn_manager

	for player_id in player_manager.get_player_ids():
		turn_manager.add_player(player_id)

	turn_manager.next_turn()
