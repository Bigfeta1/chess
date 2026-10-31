extends Node

@onready var game_initializer = $GameInitializer

func initialize(logic):
	game_initializer.initialize(logic)
