extends Button

# Returns to the main menu.

func _pressed() -> void:
	GameState.state_change_requested.emit(GameState.State.MAIN_MENU)
