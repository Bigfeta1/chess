extends Node

@onready var logic = $Logic
@onready var ui = $UI
@onready var world = $"3D"
@onready var state_router = $StateRouter

func _ready():
	state_router.initialize(logic, ui, world)
