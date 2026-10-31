extends Control

@onready var end_turn_button = $Button
@onready var turn_label = $TurnLabel
@onready var phase_label = $PhaseLabel
@onready var promotion_panel = $PromotionPanel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(state_manager, phase_manager, turn_manager, promotion_manager):
	end_turn_button.initialize(state_manager)
	phase_label.initialize(phase_manager)
	turn_label.initialize(turn_manager)
	promotion_panel.initialize(promotion_manager)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
