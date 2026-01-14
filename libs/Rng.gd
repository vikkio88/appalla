extends Node
class_name Rng

static func vec2(variation: float) -> Vector2:
	return Vector2(
			randf_range(-variation, variation),
			randf_range(-variation, variation)
		)
