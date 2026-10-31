extends Node

@onready var event_coordinators = $EventCoordinators

func initialize(logic):
	event_coordinators.initialize(logic)
