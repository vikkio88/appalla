extends CharacterBody2D

@onready var sprite := $sprite

const MAX_SPEED := 500.0
const ACCELERATION := 800.0
const FRICTION := 1800.0

func _physics_process(delta: float) -> void:
	var input := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	if input.length() > 0.0:
		input = input.normalized()
		velocity = velocity.move_toward(input * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if velocity.length() > 0.1:
		sprite.rotation = velocity.angle()

	move_and_slide()
