extends CharacterBody2D

const FRICTION := 2000.0
const PUSH_FORCE := 600.0
const MIN_SPEED := 20.0
const NEARBY := 30.0
const POSSESSION_DISTANCE = 20.0
var owner_position = null

func stop():
	velocity = Vector2.ZERO

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		return
		
	if body is CharacterBody2D:
		var mouse_pos = get_global_mouse_position();
		print_debug(body.velocity.length())
		print_debug(mouse_pos.distance_to(global_position))
		if mouse_pos.distance_to(global_position) < NEARBY:
			velocity = Vector2.ZERO
			owner_position = body.global_position
		elif body.velocity.length() > MIN_SPEED:
			var player_direction = -1 if body.velocity.x < 0 else 1
			position = body.position + Vector2(player_direction * 5,0)
			var direction :Vector2 = (mouse_pos - global_position).normalized()
			velocity = direction * PUSH_FORCE
			owner_position = null
		else:
			owner_position = null

func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("ball"):
		return
		
	if body is CharacterBody2D and body.global_position.distance_to(global_position) > 25:
		owner_position = null


func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	if owner_position:
		var dir :Vector2= (mouse_pos - owner_position).normalized()
		global_position = owner_position + dir * POSSESSION_DISTANCE
	
	if velocity.length() > 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide()
