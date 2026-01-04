extends Camera2D

@export var target: Node2D
@export var speed: float = 5.0


func _process(delta: float) -> void:
	if target:
		global_position = global_position.lerp(target.global_position, delta * speed)
