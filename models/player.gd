extends CharacterBody2D
class_name Player

@onready var sprite := $sprite

const MAX_SPEED := 200.0
const TARGET_NEARBY := 10.0

var target = null

func stop():
	velocity = Vector2.ZERO
	target = null

func select_target(new_target: Vector2):
	target = new_target

const ACCEL := 400.0

func _physics_process(_delta: float) -> void:
	if target != null and global_position.distance_to(target) > TARGET_NEARBY:
		var direction = (target - global_position).normalized()
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCEL * _delta)
	else:
		velocity = Vector2.ZERO

	move_and_slide()
