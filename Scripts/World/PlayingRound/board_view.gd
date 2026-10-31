extends Node3D

# Draws the board in 3D from the board manager's squares.
# Reads from logic; sends clicked squares to the selection manager.

@export var square_size := 1.0
@export var square_thickness := 0.1
@export var light_color := Color(0.93, 0.87, 0.75)
@export var dark_color := Color(0.45, 0.32, 0.22)
@export var selected_color := Color(0.85, 0.75, 0.25)

@onready var squares_root = $Squares
@onready var pieces_root = $Pieces
@onready var camera = $Camera3D
@onready var light = $DirectionalLight3D
@onready var board_input = $BoardInput

var piece_view = preload("res://Scenes/PlayingRound/piece_view.tscn")

var board_manager
var selection_manager
var square_views := {}
var piece_views := {}

var light_material: StandardMaterial3D
var dark_material: StandardMaterial3D
var selected_material: StandardMaterial3D
var highlighted_square = null

func initialize(board_mngr, selection_mngr) -> void:
	board_manager = board_mngr
	selection_manager = selection_mngr

	build_board()
	build_pieces()
	place_camera()

	board_input.initialize(camera, self)
	board_input.square_clicked.connect(selection_manager.select_square)
	selection_manager.selection_changed.connect(_on_selection_changed)

func build_pieces() -> void:
	for square in board_manager.squares.values():
		if square.is_empty():
			continue

		var view = piece_view.instantiate()
		view.name = square.piece.name
		pieces_root.add_child(view)
		var square_position = square_to_position(square.file, square.rank)
		# Piece origin is its foot: put it on the board's top surface (y = 0).
		view.position = Vector3(square_position.x, 0.0, square_position.z)
		view.initialize(square.piece)
		piece_views[square.piece] = view

func build_board() -> void:
	var mesh = BoxMesh.new()
	mesh.size = Vector3(square_size, square_thickness, square_size)

	light_material = make_material(light_color)
	dark_material = make_material(dark_color)
	selected_material = make_material(selected_color)

	for square in board_manager.squares.values():
		var view = MeshInstance3D.new()
		view.name = square.square_name
		view.mesh = mesh
		view.material_override = get_square_material(square)
		view.position = square_to_position(square.file, square.rank)
		squares_root.add_child(view)
		square_views[square.square_name] = view

func make_material(color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	return material

func get_square_material(square) -> StandardMaterial3D:
	return light_material if square.is_light else dark_material

func _on_selection_changed(piece) -> void:
	if highlighted_square != null:
		square_views[highlighted_square.square_name].material_override = get_square_material(highlighted_square)
		highlighted_square = null

	if piece == null or piece.square == null:
		return

	highlighted_square = piece.square
	square_views[highlighted_square.square_name].material_override = selected_material

# Board is centred on the origin. Files run along +X (a to h),
# ranks run along -Z (1 to 8), so rank 1 faces a camera on +Z.
func square_to_position(file: int, rank: int) -> Vector3:
	var half = (board_manager.BOARD_SIZE - 1) / 2.0
	return Vector3(
		(file - half) * square_size,
		-square_thickness / 2.0,
		-(rank - half) * square_size
	)

# Inverse of square_to_position. Takes a point in this node's local space;
# returns the square under it, or null if it is off the board.
func position_to_square(local_position: Vector3):
	var half = (board_manager.BOARD_SIZE - 1) / 2.0
	var file = roundi(local_position.x / square_size + half)
	var rank = roundi(-local_position.z / square_size + half)
	return board_manager.get_square_at(file, rank)

func place_camera() -> void:
	camera.look_at_from_position(Vector3(0, 8, 6) * square_size, Vector3.ZERO)
	light.rotation_degrees = Vector3(-60, 30, 0)
