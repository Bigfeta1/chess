extends Node

# Turns left clicks into board squares.
# First checks for a piece's click body under the mouse (so clicking the
# upper part of a piece selects that piece), then falls back to the square
# under the mouse on the board surface (y = 0).

signal square_clicked(square)
# The tactical_view input action (F5 by default) was pressed.
signal tactical_view_toggled

const RAY_LENGTH := 100.0

var camera: Camera3D
var board_view

var pending_click = null

func initialize(camera_reference: Camera3D, board_view_reference) -> void:
	camera = camera_reference
	board_view = board_view_reference

func _unhandled_input(event: InputEvent) -> void:
	if camera == null:
		return

	if event.is_action_pressed("tactical_view"):
		tactical_view_toggled.emit()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Physics queries are made in _physics_process, where the space is safe to read.
		pending_click = event.position
		get_viewport().set_input_as_handled()

func _physics_process(_delta: float) -> void:
	if pending_click == null:
		return

	var mouse_position = pending_click
	pending_click = null
	square_clicked.emit(find_square(mouse_position))

func find_square(mouse_position: Vector2):
	var from = camera.project_ray_origin(mouse_position)
	var direction = camera.project_ray_normal(mouse_position)

	var piece = find_piece(from, direction)
	if piece != null:
		return piece.square

	var hit = Plane(Vector3.UP, 0.0).intersects_ray(from, direction)
	if hit == null:
		return null

	return board_view.position_to_square(board_view.to_local(hit))

func find_piece(from: Vector3, direction: Vector3):
	var query = PhysicsRayQueryParameters3D.create(from, from + direction * RAY_LENGTH)
	var result = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null

	var piece_view = result.collider.get_parent()
	return piece_view.piece
