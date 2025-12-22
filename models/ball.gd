extends CharacterBody2D

const FRICTION := 2000.0
const PUSH_FORCE := 600.0
const MIN_SPEED := 1.0

func stop():
	velocity = Vector2.ZERO

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		return
		
	if body is CharacterBody2D:
		var player_direction = -1 if body.velocity.x < 0 else 1
		position = body.position + Vector2(player_direction * 5,0)
		var direction :Vector2 = (get_global_mouse_position() - global_position).normalized()
		velocity = direction * PUSH_FORCE


func _physics_process(delta: float) -> void:
	if velocity.length() > 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide()
