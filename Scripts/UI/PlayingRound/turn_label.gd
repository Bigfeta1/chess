extends Label

var turn_manager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(turn_mngr):
	turn_manager = turn_mngr
	turn_manager.turn_changed.connect(draw_text)
	draw_text(turn_manager.get_current_player())

func draw_text(new_turn):
	if turn_manager != null:
		if new_turn == null:
			text = "STANDBY"
		else:
			text = new_turn
