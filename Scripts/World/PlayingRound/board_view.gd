extends Node3D

# Draws the board in 3D from the board manager's squares.
# Reads from logic; sends clicked squares to the selection manager.
# Highlights the selected piece's square, its moves and its blocked moves,
# and moves piece views when the move manager moves a piece.
# Captured pieces line up beside the board: white's captures in front of
# rank 1, black's behind rank 8, in the capturing player's captured order.
# A promoted pawn's view is replaced by a view of the piece it became.
# The tactical view (toggled by the tactical_view action, F5) tints every
# square the current player's pieces threaten.
# Square colours are layered: selection highlights, then tactical view
# tints, then the plain light or dark colour.

@export var square_size := 1.0
@export var square_thickness := 0.1
@export var light_color := Color(0.93, 0.87, 0.75)
@export var dark_color := Color(0.45, 0.32, 0.22)
@export var selected_color := Color(0.85, 0.75, 0.25)
@export var move_color := Color(0.4, 0.7, 0.35)
@export var blocked_color := Color(0.75, 0.3, 0.28)

# Tactical view. Each tint is mixed into the square's own colour by its
# strength (0 to 1), so the light and dark pattern still shows.
@export var threat_color := Color(0.95, 0.55, 0.15)
@export_range(0.0, 1.0) var threat_strength := 0.45
@export var threatened_piece_color := Color(0.85, 0.15, 0.15)
@export_range(0.0, 1.0) var threatened_piece_strength := 0.7

# Captured piece lines. Scale is relative to a piece on the board.
# Distances are in squares. The camera views from white's side, so white's
# line is in front of the board and black's behind it. The back line sits
# further out so the back-rank pieces do not hide it.
@export var captured_scale := 0.5
@export var captured_margin_front := 0.6
@export var captured_margin_back := 1.6
@export var captured_spacing := 0.3
@export var captured_group_spacing := 0.6

@onready var squares_root = $Squares
@onready var pieces_root = $Pieces
@onready var camera = $Camera3D
@onready var light = $DirectionalLight3D
@onready var board_input = $BoardInput

var piece_view = preload("res://Scenes/PlayingRound/piece_view.tscn")

const PlayerManager = preload("res://Scripts/Logic/PlayingRound/Players/player_manager.gd")

var board_manager
var selection_manager
var move_manager
var turn_manager
var player_manager
var promotion_manager
var square_views := {}
var piece_views := {}

var light_material: StandardMaterial3D
var dark_material: StandardMaterial3D
var selected_material: StandardMaterial3D
var move_material: StandardMaterial3D
var blocked_material: StandardMaterial3D
# Keyed by is_light: the tint differs on light and dark squares.
var threat_materials := {}
var threatened_piece_materials := {}

# Highlight layers: square -> material. Selection wins over threats.
var selection_highlights := {}
var threat_highlights := {}
var tactical_view := false

func initialize(board_mngr, selection_mngr, move_mngr, turn_mngr, player_mngr, promotion_mngr) -> void:
	board_manager = board_mngr
	selection_manager = selection_mngr
	move_manager = move_mngr
	turn_manager = turn_mngr
	player_manager = player_mngr
	promotion_manager = promotion_mngr

	build_board()
	build_pieces()
	place_camera()

	board_input.initialize(camera, self)
	board_input.square_clicked.connect(selection_manager.select_square)
	selection_manager.selection_changed.connect(_on_selection_changed)
	move_manager.piece_moved.connect(_on_piece_moved)
	move_manager.piece_captured.connect(_on_piece_captured)
	board_input.tactical_view_toggled.connect(_on_tactical_view_toggled)
	turn_manager.turn_changed.connect(_on_turn_changed)
	promotion_manager.piece_promoted.connect(_on_piece_promoted)

func build_pieces() -> void:
	for square in board_manager.squares.values():
		if not square.is_empty():
			add_piece_view(square.piece)

# Creates the view for a piece standing on the board.
func add_piece_view(piece) -> void:
	var view = piece_view.instantiate()
	view.name = piece.name
	pieces_root.add_child(view)
	view.position = piece_position(piece.square)
	view.initialize(piece)
	piece_views[piece] = view

# The pawn's view goes; the new piece appears on the pawn's square.
func _on_piece_promoted(pawn, new_piece) -> void:
	var old_view = piece_views[pawn]
	piece_views.erase(pawn)
	pieces_root.remove_child(old_view)
	old_view.queue_free()

	add_piece_view(new_piece)
	update_threats()

func build_board() -> void:
	var mesh = BoxMesh.new()
	mesh.size = Vector3(square_size, square_thickness, square_size)

	light_material = make_material(light_color)
	dark_material = make_material(dark_color)
	selected_material = make_material(selected_color)
	move_material = make_material(move_color)
	blocked_material = make_material(blocked_color)
	for is_light in [true, false]:
		var base = light_color if is_light else dark_color
		threat_materials[is_light] = make_material(base.lerp(threat_color, threat_strength))
		threatened_piece_materials[is_light] = make_material(base.lerp(threatened_piece_color, threatened_piece_strength))

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
	selection_highlights.clear()

	if piece != null and piece.square != null:
		selection_highlights[piece.square] = selected_material
		for square in piece.get_moves(board_manager):
			selection_highlights[square] = move_material
		for square in piece.get_blocked_moves(board_manager):
			selection_highlights[square] = blocked_material

	refresh_squares()

func _on_tactical_view_toggled() -> void:
	tactical_view = not tactical_view
	update_threats()

func _on_turn_changed(_new_turn) -> void:
	update_threats()

# Recomputes the tactical view tints for the player whose turn it is.
func update_threats() -> void:
	threat_highlights.clear()

	var player = get_current_player()
	if tactical_view and player != null:
		for square in player.get_threatened_squares(board_manager):
			var materials = threat_materials if square.is_empty() else threatened_piece_materials
			threat_highlights[square] = materials[square.is_light]

	refresh_squares()

func get_current_player():
	var player_id = turn_manager.get_current_player()
	if player_id == null:
		return null
	return player_manager.get_player(player_id)

# Gives every square the material of its top highlight layer.
func refresh_squares() -> void:
	for square in board_manager.squares.values():
		var material = selection_highlights.get(square, threat_highlights.get(square, get_square_material(square)))
		square_views[square.square_name].material_override = material

func _on_piece_moved(piece, _from_square, to_square) -> void:
	piece_views[piece].move_to(piece_position(to_square))
	update_threats()

# The captured piece waits for the capturing piece to land, then goes to its
# place in the capturing player's line. Pieces already in the line move along
# at the same time to make room.
func _on_piece_captured(captured_piece, capturing_piece, capturing_player) -> void:
	piece_views[captured_piece].set_captured()
	var delay = piece_views[capturing_piece].get_move_duration()
	var positions = get_captured_positions(capturing_player)
	for i in capturing_player.captured_pieces.size():
		piece_views[capturing_player.captured_pieces[i]].move_to(positions[i], delay, captured_scale)

# Positions along a player's captured line, one per captured piece, in order.
# Same-type pieces sit close together; a new type starts after a wider gap.
func get_captured_positions(player) -> Array:
	var half_board = board_manager.BOARD_SIZE / 2.0 * square_size
	var row_z = half_board + captured_margin_front * square_size
	if player.team == PlayerManager.Team.BLACK:
		row_z = -(half_board + captured_margin_back * square_size)

	var positions := []
	var x = -half_board + captured_spacing * square_size
	var previous = null
	for piece in player.captured_pieces:
		if previous != null:
			var gap = captured_spacing if piece.piece_type == previous.piece_type else captured_group_spacing
			x += gap * square_size
		positions.append(Vector3(x, 0.0, row_z))
		previous = piece
	return positions

# A piece's origin is its foot: on the square centre, at the board's top surface (y = 0).
func piece_position(square) -> Vector3:
	var square_position = square_to_position(square.file, square.rank)
	return Vector3(square_position.x, 0.0, square_position.z)

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
