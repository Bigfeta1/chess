extends RefCounted

# Turns elapsed time into progress along a slide, shaped by an ADSR speed
# envelope, as on a synthesiser:
#   attack:  speed ramps from 0 up to its peak
#   decay:   speed falls from the peak to the sustain level
#   sustain: speed holds at that level
#   release: speed falls to 0 as the piece lands
# attack, decay and release are fractions of the move's duration; sustain
# fills what is left. sustain_level is a fraction of the peak speed.
# Progress is the distance covered so far (the area under the speed curve),
# scaled so it always ends at exactly 1.

# Speed curve as (time, speed) points; time runs 0 to 1.
static func build(attack: float, decay: float, sustain_level: float, release: float) -> Array:
	attack = maxf(attack, 0.0)
	decay = maxf(decay, 0.0)
	release = maxf(release, 0.0)
	sustain_level = clampf(sustain_level, 0.0, 1.0)

	# If the phases add up to more than the whole move, shrink them to fit.
	var total = attack + decay + release
	if total > 1.0:
		attack /= total
		decay /= total
		release /= total

	return [
		Vector2(0.0, 0.0),
		Vector2(attack, 1.0),
		Vector2(attack + decay, sustain_level),
		Vector2(1.0 - release, sustain_level),
		Vector2(1.0, 0.0)
	]

# Progress (0 to 1) at time u (0 to 1) along the curve.
static func progress(curve: Array, u: float) -> float:
	u = clampf(u, 0.0, 1.0)
	var covered = 0.0
	var total = 0.0

	for i in curve.size() - 1:
		var a: Vector2 = curve[i]
		var b: Vector2 = curve[i + 1]
		var width = b.x - a.x
		if width <= 0.0:
			continue

		total += (a.y + b.y) / 2.0 * width

		if u > a.x:
			var end = minf(u, b.x)
			var speed_at_end = lerpf(a.y, b.y, (end - a.x) / width)
			covered += (a.y + speed_at_end) / 2.0 * (end - a.x)

	if total <= 0.0:
		return u
	return covered / total
