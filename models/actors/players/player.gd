extends CharacterBody2D
class_name Player

@onready var shirt_number = $shirt_number
@onready var sprite := $sprite
@onready var select_indicator = $select_indicator
@onready var tick = $tick

@export var number: int = 0
@export var team: Enums.TeamSide = Enums.TeamSide.Home
@export var defense_position: Vector2 = Vector2.ZERO
@export var attack_position: Vector2 = Vector2.ZERO
@export var position_variation: int = 40

const MAX_SPEED := 200.0
const TARGET_NEARBY := 15.0
const ACCEL := 400.0
const PUSH_FORCE := 700.0
const SHOOTING_FORCE := 1800.0
const POSSESSION_DISTANCE = 15.0

var decision: Ai.Decision = Ai.Decision.Wait

var is_selected := false:
	set(new_value):
		stop()
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
	ball.shoot(dir, SHOOTING_FORCE * strenght, self)


func push(towards: Vector2):
	if ball:
		var direction = (towards - global_position).normalized()
		var distance = global_position.distance_to(towards)
		var force = PUSH_FORCE
		if distance < 100:
			force *= 0.5
		ball.push(direction, force, self)


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
	if body is Ball and not has_ball_owner_nearby:
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


func _on_tick_timeout() -> void:
	var delta := randf_range(.2, .5) * (1.0 if randf() < 0.5 else -1.0)
	tick.wait_time = max(0.4, tick.wait_time + delta)
	
	if (has_ball() and self.team == MatchState.user_side) or is_selected:
		return
	
	if decision == Ai.Decision.ChaseBall and MatchState.ball_position.distance_to(global_position) < TARGET_NEARBY * 20:
		return
	
	var variation := Vector2(
			randf_range(-position_variation, position_variation),
			randf_range(-position_variation, position_variation)
		)
	
	if MatchState.ball_owner and MatchState.ball_owner.team == self.team and MatchState.ball_position.x > 650:
		decision = Ai.Decision.Attack
		target = attack_position + variation
	else:
		decision = Ai.Decision.Defense
		target = defense_position + variation


var has_ball_owner_nearby = false
func _on_detector_body_entered(body: Node2D) -> void:
	if body is Player and not self.is_same(body):
		if body.has_ball() and body.team == self.team:
			print_debug("player %s detected teammate with ball %s" % [ self.number, body.number])
			has_ball_owner_nearby = true

func _on_detector_body_exited(body: Node2D) -> void:
	if body is Player and not self.is_same(body):
		if body.has_ball() and body.team == self.team:
			print_debug("player %s detected teammate with ball %s leaving" % [ self.number, body.number])
			has_ball_owner_nearby = false
