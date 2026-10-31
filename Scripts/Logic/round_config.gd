extends Node

# Holds the choices made on the round config panel.
# Panel controls write here; configurator steps read from here.
var settings := {}

func set_setting(key: String, value) -> void:
	settings[key] = value

func get_setting(key: String, default = null):
	return settings.get(key, default)

# Override or extend to block BEGIN until required settings are chosen.
func is_valid() -> bool:
	return true
