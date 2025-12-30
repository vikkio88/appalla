extends CharacterBody2D
class_name Player

@onready var sprite := $sprite
@onready var shirt_number = $shirt_number
@onready var select_indicator = $select_indicator

@export var number: int = 0

const MAX_SPEED := 200.0
const TARGET_NEARBY := 15.0
const ACCEL := 400.0
const PUSH_FORCE := 700.0
const SHOOTING_FORCE := 1800.0
const POSSESSION_DISTANCE = 15.0

var is_selected := false:
	set(new_value):
		is_selected = new_value
		select_indicator.visible = new_value
	get:
		return is_selected
var target = null
var ball: Ball


func _ready() -> void:
	shirt_number.text = "%s" % number


func is_same(other: Player) -> bool:
	return self.number == other.number


func has_ball() -> bool:
	return ball != null


func stop():
	velocity = Vector2.ZERO
	target = null


func shoot(strenght: float):
	if !ball:
		return
	var mouse_pos = get_global_mouse_position()
	var dir: Vector2 = (mouse_pos - global_position).normalized()
	ball.shoot(dir, SHOOTING_FORCE * strenght)


func push(towards: Vector2):
	if ball:
		var direction = (towards - global_position).normalized()
		var distance = global_position.distance_to(towards)
		var force = PUSH_FORCE
		if distance < 100:
			force *= 0.5
		ball.push(direction, force)


func select_target(new_target: Vector2):
	if ball:
		push(new_target)
	target = new_target


func _physics_process(_delta: float) -> void:
	var is_target_nearby = target and target.distance_to(global_position) <= TARGET_NEARBY
	if is_target_nearby:
		stop()

	if ball and target == null:
		var mouse_pos = get_global_mouse_position()
		var dir: Vector2 = (mouse_pos - global_position).normalized()
		ball.global_position = global_position + dir * POSSESSION_DISTANCE
	if target and not is_target_nearby:
		var direction = (target - global_position).normalized()
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCEL * _delta)
	elif target != null:
		stop()
	move_and_slide()


func _on_ball_possession_body_entered(body: Node2D) -> void:
	if body is Ball:
		ball = body
		EventBus.ball_possession_change.emit(self)
		if (
			target == null
			or target.distance_to(ball.global_position) < 15
			or target.distance_to(global_position) < TARGET_NEARBY
		):
			stop()
			ball.stop()
		else:
			push(target)


func _on_ball_possession_body_exited(body: Node2D) -> void:
	if body is Ball:
		ball = null


func _on_ball_possession_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("Click"):
		EventBus.clicked_player.emit(self)
