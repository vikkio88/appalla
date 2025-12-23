extends CharacterBody2D
class_name Ball

const FRICTION := 1800.0
const PUSH_FORCE := 700.0
const MIN_SPEED := 20.0
const NEARBY := 30.0
const POSSESSION_DISTANCE = 15.0
var owner_position = null

func stop():
	velocity = Vector2.ZERO
	
func hold(holder: Player):
	holder.stop()
	velocity = Vector2.ZERO
	owner_position = holder.global_position
	pass

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		return
		
	if body is Player:
		#var mouse_pos = get_global_mouse_position();
		if body.target and body.target.distance_to(global_position) < NEARBY:
			print("holding")
			hold(body)
		elif body.velocity.length() > MIN_SPEED or (body.target and body.target.distance_to(global_position) > NEARBY):
			print("push")
			#var x_multi = -1 if body.target.x < global_position.x else 1
			#global_position = body.global_position + Vector2(x_multi * 5, 0)
			#var direction :Vector2 = (mouse_pos - global_position).normalized()
			var direction = (body.target - global_position).normalized()
			var distance = global_position.distance_to(body.target)
			var force = PUSH_FORCE
			if distance < 100:
				force *= 0.5
			print("pushdir: ", direction)
			print("pushforce: ", force)
			velocity = direction * force
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
