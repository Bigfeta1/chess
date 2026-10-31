extends RefCounted

# Measures where the solid (alpha >= 0.5) pixels of a sprite texture are,
# so pieces can be cropped to the drawn piece, scaled by its real height and
# anchored on its real base, however much empty space the image has around it.
# Results are cached per texture path.

# Images are measured on a scaled-down copy for speed; this is its height.
const SAMPLE_HEIGHT := 256
const SOLID_ALPHA := 0.5
# Fraction of the solid height at the bottom that counts as the base.
const BASE_FRACTION := 0.15

static var cache := {}

# Returns { "rect": Rect2 of solid pixels in texture pixels,
#           "base_half_width": half the width of the base in texture pixels,
#           "base_center_x": x of the base's centre in texture pixels }.
static func measure(texture: Texture2D) -> Dictionary:
	if cache.has(texture.resource_path):
		return cache[texture.resource_path]

	var image = texture.get_image()
	var scale = float(image.get_height()) / SAMPLE_HEIGHT
	var sample_width = maxi(1, roundi(image.get_width() / scale))
	image.resize(sample_width, SAMPLE_HEIGHT, Image.INTERPOLATE_BILINEAR)

	var min_x = sample_width
	var max_x = -1
	var min_y = SAMPLE_HEIGHT
	var max_y = -1
	var row_extents := {}

	for y in SAMPLE_HEIGHT:
		for x in sample_width:
			if image.get_pixel(x, y).a < SOLID_ALPHA:
				continue
			min_x = mini(min_x, x)
			max_x = maxi(max_x, x)
			min_y = mini(min_y, y)
			max_y = maxi(max_y, y)
			# x runs left to right, so the first hit is the row's left edge
			# and the last hit is its right edge.
			var extent: Vector2i = row_extents.get(y, Vector2i(x, x))
			extent.y = x
			row_extents[y] = extent

	if max_x < 0:
		var empty = {
			"rect": Rect2(Vector2.ZERO, texture.get_size()),
			"base_half_width": 0.0,
			"base_center_x": texture.get_width() / 2.0
		}
		cache[texture.resource_path] = empty
		return empty

	# Widest row in the bottom slice of the piece is its base.
	var base_rows = maxi(1, roundi((max_y - min_y + 1) * BASE_FRACTION))
	var base_left = max_x
	var base_right = min_x
	for y in range(max_y - base_rows + 1, max_y + 1):
		if row_extents.has(y):
			base_left = mini(base_left, row_extents[y].x)
			base_right = maxi(base_right, row_extents[y].y)

	var result = {
		"rect": Rect2(min_x * scale, min_y * scale, (max_x - min_x + 1) * scale, (max_y - min_y + 1) * scale),
		"base_half_width": (base_right - base_left + 1) * scale / 2.0,
		"base_center_x": (base_left + base_right + 1) * scale / 2.0
	}
	cache[texture.resource_path] = result
	return result
