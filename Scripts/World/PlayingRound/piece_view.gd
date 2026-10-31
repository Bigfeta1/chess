extends Node3D

# Shows one piece on the 3D board: a camera-facing sprite standing on
# a soft blob shadow. The node's origin is the piece's foot on the board.
# Texture comes from Assets/Pieces/<Team>/<team>_<type>.png, e.g.
# Assets/Pieces/White/white_pawn.png. If the file is missing, nothing is shown.

const Piece = preload("res://Scripts/Logic/PlayingRound/Pieces/piece.gd")
const SpriteBounds = preload("res://Scripts/World/PlayingRound/sprite_bounds.gd")
const PlayerManager = preload("res://Scripts/Logic/PlayingRound/Players/player_manager.gd")
const SPRITE_PATH := "res://Assets/Pieces/%s/%s_%s.png"

# Every sprite image is framed to fill its canvas, so the image itself says
# nothing about how tall the piece is. Heights come from here instead:
# the king's height in world units (one square is 1.0), and every other piece
# as a fraction of it. Ratios follow FIDE's recommended piece heights
# (king 9.5 cm, pawn 5), except the queen, which is drawn as tall as the
# king, and the bishop, knight and rook, which are drawn larger than FIDE's
# bishop 7 cm, knight 6 cm and rook 5.5 cm.
@export var king_height := 1.4
const HEIGHT_RATIOS = {
	Piece.PieceType.KING: 1.0,
	Piece.PieceType.QUEEN: 1.0,
	Piece.PieceType.BISHOP: 0.85,
	Piece.PieceType.KNIGHT: 0.72,
	Piece.PieceType.ROOK: 0.67,
	Piece.PieceType.PAWN: 0.53
}
# How far the sprite is moved toward the camera (+Z), as a fraction of the
# piece's base half-width. The sprite's bottom edge is the front of the base:
# 0 puts that edge on the square centre (base looks pushed back), 1 puts the
# base's true centre there (base looks pushed forward). 0.5 centres the
# visible base on the square.
@export var base_forward := 0.5
# Radius of the blob shadow, as a multiple of the piece's base half-width.
@export var shadow_scale := 1.4
# Darkness of the shadow at its centre (0 to 1).
@export var shadow_strength := 0.55

@onready var sprite = $Sprite
@onready var shadow = $Shadow
@onready var click_shape = $ClickBody/ClickShape
@onready var motion = $Motion

var piece
var piece_height := 0.0
var base_radius := 0.0

func _ready() -> void:
	# Face the camera fully so the sprite is never squashed by the camera tilt.
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	# Hard-edged transparency so overlapping sprites sort correctly.
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.visible = false
	shadow.visible = false
	click_shape.disabled = true

func initialize(piece_reference) -> void:
	piece = piece_reference
	motion.initialize(self, sprite, shadow, piece.piece_type)
	set_sprite()

# Animates the piece to target_position (its foot on the board).
func move_to(target_position: Vector3) -> void:
	motion.move_to(target_position)

func set_sprite() -> void:
	var path = get_sprite_path()
	if not ResourceLoader.exists(path):
		return

	piece_height = king_height * HEIGHT_RATIOS[piece.piece_type]

	var texture = load(path)
	var bounds = SpriteBounds.measure(texture)
	var solid: Rect2 = bounds.rect

	# Draw only the solid part of the image, so empty space around the
	# piece does not affect its size or where its base sits.
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = solid
	sprite.pixel_size = piece_height / solid.size.y

	# Lift the quad by half its height so its bottom edge (the base) sits on
	# the node origin; the billboard then pivots around the piece's foot.
	# Shift sideways so the middle of the base, not the middle of the
	# image, is over the origin.
	sprite.flip_h = should_flip()
	var base_offset_x = bounds.base_center_x - solid.get_center().x
	if sprite.flip_h:
		base_offset_x = -base_offset_x
	sprite.offset = Vector2(-base_offset_x, solid.size.y / 2.0)

	# Move the sprite toward the camera so its base sits on the square centre.
	base_radius = bounds.base_half_width * sprite.pixel_size
	sprite.position.z = base_radius * base_forward
	sprite.visible = true

	build_shadow()
	build_click_shape()

# Upright box around the piece so clicking any part of it hits the piece.
func build_click_shape() -> void:
	var box = BoxShape3D.new()
	box.size = Vector3(base_radius * 2.0, piece_height, base_radius * 2.0)
	click_shape.shape = box
	click_shape.position = Vector3(0, piece_height / 2.0, 0)
	click_shape.disabled = false

func build_shadow() -> void:
	var gradient = Gradient.new()
	gradient.set_color(0, Color(0, 0, 0, shadow_strength))
	gradient.set_color(1, Color(0, 0, 0, 0))

	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.fill_from = Vector2(0.5, 0.5)
	gradient_texture.fill_to = Vector2(1.0, 0.5)

	var material = StandardMaterial3D.new()
	material.albedo_texture = gradient_texture
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var mesh = PlaneMesh.new()
	var shadow_radius = base_radius * shadow_scale
	mesh.size = Vector2(shadow_radius * 2.0, shadow_radius * 2.0)

	shadow.mesh = mesh
	shadow.material_override = material
	# Just above the board surface to avoid z-fighting.
	shadow.position.y = 0.005
	shadow.visible = true

# Pieces whose art faces one way. On the kingside (files e-h) these are
# mirrored so each pair faces each other.
const FLIPPED_ON_KINGSIDE = [
	Piece.PieceType.KNIGHT,
	Piece.PieceType.BISHOP
]

# Decided once, from the square the piece starts on.
func should_flip() -> bool:
	if not FLIPPED_ON_KINGSIDE.has(piece.piece_type) or piece.square == null:
		return false
	return piece.square.file >= 4

func get_sprite_path() -> String:
	var team_name = String(PlayerManager.Team.find_key(piece.team)).to_lower()
	var type_name = String(piece.PieceType.find_key(piece.piece_type)).to_lower()
	return SPRITE_PATH % [team_name.capitalize(), team_name, type_name]
