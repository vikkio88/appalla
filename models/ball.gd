extends CharacterBody2D
class_name Ball

const FRICTION := 1800.0
const MIN_SPEED := 20.0
const NEARBY := 30.0

var last_touched_by: Player


func stop():
	velocity = Vector2.ZERO


func push(direction: Vector2, force: float, player: Player):
	velocity = direction * force
	last_touched_by = player


func shoot(direction: Vector2, force: float, player: Player):
	velocity = direction * force
	last_touched_by = player


func _physics_process(delta: float) -> void:
	if velocity.length() > 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()
