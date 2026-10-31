extends Node

enum RoundPhase {
	START_PHASE,
	MAIN_PHASE,
	END_PHASE,
	STANDBY
}

var current_phase: RoundPhase = RoundPhase.STANDBY

signal phase_change_requested(new_phase: RoundPhase)
signal phase_changed(new_phase: RoundPhase)

func _ready():
	phase_change_requested.connect(advance_phase)

func advance_phase(new_phase: RoundPhase):
	if current_phase == new_phase:
		pass
	
	current_phase = new_phase
	phase_changed.emit(current_phase)
