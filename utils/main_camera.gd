extends Camera2D

@export var target: Node2D
@export var speed: float = 1.0
const NEARBY_DISTANCE := 600.0


func _process(delta: float) -> void:
	if not target:
		return

	var dx := target.global_position.x - global_position.x

	if abs(dx) <= NEARBY_DISTANCE:
		return

	global_position.x = lerp(global_position.x, target.global_position.x, delta * speed)
