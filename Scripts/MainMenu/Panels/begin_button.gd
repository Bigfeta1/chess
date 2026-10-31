extends Button

var config

func initialize(round_config):
	config = round_config

func _pressed() -> void:
	if not config.is_valid():
		return

	GameState.state_change_requested.emit(GameState.State.CONFIGURE_ROUND)
