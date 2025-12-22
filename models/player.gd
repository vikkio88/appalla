extends CharacterBody2D

@onready var sprite := $sprite

const MAX_SPEED := 200.0
const TARGET_NEARBY := 10.0

var target = null

func stop():
	velocity = Vector2.ZERO
	target = null

func _physics_process(_delta: float) -> void:
	if target != null and global_position.distance_to(target) > TARGET_NEARBY:
		var direction :Vector2= (target - global_position).normalized()
		velocity = direction * MAX_SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
