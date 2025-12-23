extends CharacterBody2D
class_name Player

@onready var sprite := $sprite

const MAX_SPEED := 200.0
const TARGET_NEARBY := 10.0

var target = null
var ball_nearby:Ball

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
	elif target != null:
		velocity = Vector2.ZERO
		target = null
		if ball_nearby:
			ball_nearby.hold(self)
		

	move_and_slide()


func _on_ball_possession_body_entered(body: Node2D) -> void:
	if body is Ball:
		ball_nearby = body


func _on_ball_possession_body_exited(body: Node2D) -> void:
	if body is Ball:
		ball_nearby = null
