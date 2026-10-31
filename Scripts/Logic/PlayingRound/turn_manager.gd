extends Node

signal turn_change_requested(new_turn: int)
signal turn_changed(new_turn)

var turn_order: Array = []
var current_turn_index: int = -1

func _ready():
	pass
	
func add_player(player_id: String):
	if not turn_order.has(player_id):
		turn_order.append(player_id)

func get_current_player():
	if current_turn_index < 0 or current_turn_index >= turn_order.size():
		return null
	return turn_order[current_turn_index]

#region Turn Order
func next_turn():
	if turn_order.is_empty():
		return
	
	var next_turn_index = current_turn_index + 1
	
	if next_turn_index >= turn_order.size():
		next_turn_index = 0
	
	var next_player = turn_order[next_turn_index]
	
	change_turn(next_player)

func change_turn(new_turn: String):
	var new_turn_index = turn_order.find(new_turn)
	
	if new_turn_index == -1:
		return
	
	if current_turn_index == new_turn_index:
		return
		
	current_turn_index = new_turn_index
	turn_changed.emit(new_turn)
	
#endregion
