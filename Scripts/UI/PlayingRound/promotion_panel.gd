extends Control

# Shown when a pawn reaches its last rank. Offers one button per piece the
# pawn can become, drawn with that team's piece image. Pressing one asks the
# promotion manager to promote; the panel hides once the promotion is done.

const Piece = preload("res://Scripts/Logic/PlayingRound/Pieces/piece.gd")
const PieceSprites = preload("res://Scripts/World/PlayingRound/piece_sprites.gd")
const SpriteBounds = preload("res://Scripts/World/PlayingRound/sprite_bounds.gd")

@export var button_size := Vector2(96, 96)

@onready var choices = $Panel/Margin/Content/Choices

var promotion_manager

func initialize(promotion_mngr) -> void:
	promotion_manager = promotion_mngr
	promotion_manager.promotion_started.connect(_on_promotion_started)
	promotion_manager.piece_promoted.connect(_on_piece_promoted)
	hide()

func _on_promotion_started(pawn) -> void:
	clear_choices()
	for type in promotion_manager.CHOICES:
		choices.add_child(make_choice(type, pawn.team))
	show()

func _on_piece_promoted(_pawn, _new_piece) -> void:
	hide()
	clear_choices()

func make_choice(type: int, team: int) -> Button:
	var button = Button.new()
	button.custom_minimum_size = button_size
	button.tooltip_text = String(Piece.PieceType.find_key(type)).capitalize()
	button.icon = get_icon(type, team)
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.pressed.connect(promotion_manager.promote.bind(type))
	return button

# The piece image cropped to its solid pixels, or the type name as text if
# the image is missing.
func get_icon(type: int, team: int) -> Texture2D:
	var path = PieceSprites.get_sprite_path(team, type)
	if not ResourceLoader.exists(path):
		return null

	var texture = load(path)
	var atlas = AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = SpriteBounds.measure(texture).rect
	return atlas

func clear_choices() -> void:
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
