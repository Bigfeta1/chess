extends Node

@onready var options = $Panel/OptionsScroll/Options
@onready var begin_button = $Panel/BeginButton

func initialize(config):
	begin_button.initialize(config)
