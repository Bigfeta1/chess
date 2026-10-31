extends Node

# Animates a piece view from one square to another.
# The view slides across the board; pieces with a hop height also arc up
# while their shadow stays on the board, shrinking and fading as they rise.
# Hops ease in and out on a sine; slides follow an ADSR speed envelope.

const Piece = preload("res://Scripts/Logic/PlayingRound/Pieces/piece.gd")
const SlideEnvelope = preload("res://Scripts/World/PlayingRound/slide_envelope.gd")

# Seconds a move takes: hop_duration for pieces that hop (see HOP_HEIGHTS),
# slide_duration for everything else.
@export var hop_duration := 0.45
@export var slide_duration := 0.25
# Peak of the arc in world units (one square is 1.0), per piece type.
# Types not listed slide without leaving the board.
const HOP_HEIGHTS = {
	Piece.PieceType.KNIGHT: 0.9
}
# Shadow scale at the top of the arc.
@export var shadow_scale_at_peak := 0.6

# Slide speed envelope (see slide_envelope.gd). Attack, decay and release are
# fractions of slide_duration; sustain_level is a fraction of peak speed.
@export_range(0.0, 1.0) var slide_attack := 0.15
@export_range(0.0, 1.0) var slide_decay := 0.0
@export_range(0.0, 1.0) var slide_sustain_level := 1.0
@export_range(0.0, 1.0) var slide_release := 0.15

var view: Node3D
var sprite: Node3D
var shadow: Node3D

var tween: Tween
var from_position: Vector3
var to_position: Vector3
var from_scale := 1.0
var to_scale := 1.0
var hop_height := 0.0
var slide_curve: Array

func initialize(view_reference: Node3D, sprite_reference: Node3D, shadow_reference: Node3D, piece_type) -> void:
	view = view_reference
	sprite = sprite_reference
	shadow = shadow_reference
	hop_height = HOP_HEIGHTS.get(piece_type, 0.0)

# Seconds this piece's moves take.
func get_duration() -> float:
	return hop_duration if hop_height > 0.0 else slide_duration

# Moves the view to target_position (its foot on the board), scaling it to
# target_scale on the way. Waits delay seconds before starting.
# A move started mid-animation continues from wherever the piece is.
func move_to(target_position: Vector3, delay := 0.0, target_scale := 1.0) -> void:
	if tween != null and tween.is_valid():
		tween.kill()

	from_position = view.position
	to_position = target_position
	from_scale = view.scale.x
	to_scale = target_scale

	# Built per move, so Inspector changes apply on the next move.
	slide_curve = SlideEnvelope.build(slide_attack, slide_decay, slide_sustain_level, slide_release)

	# Time runs linearly; _step shapes it into progress.
	tween = create_tween()
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.tween_method(_step, 0.0, 1.0, get_duration())
	tween.finished.connect(_step.bind(1.0))

# u is elapsed time, 0 to 1 over the move.
func _step(u: float) -> void:
	var t: float
	if hop_height > 0.0:
		# Sine ease in and out.
		t = (1.0 - cos(PI * u)) / 2.0
	else:
		t = SlideEnvelope.progress(slide_curve, u)

	view.position = from_position.lerp(to_position, t)
	view.scale = Vector3.ONE * lerpf(from_scale, to_scale, t)

	# Parabola: 0 at both ends, 1 at the middle.
	var lift = 4.0 * t * (1.0 - t)
	sprite.position.y = hop_height * lift
	shadow.scale = Vector3.ONE * lerpf(1.0, shadow_scale_at_peak, lift if hop_height > 0.0 else 0.0)
