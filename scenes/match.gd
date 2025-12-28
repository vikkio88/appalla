extends Node2D

@onready var selected_player: Player = $Home/Player
@onready var ball: Node2D = $Ball
@onready var charger: ProgressBar = $charger
#@onready var camera:Camera2D = $MainCamera;
var hold_counter: float = 0
@export var long_click: float = .20
@export var max_long_click: float = 0.70


func _ready() -> void:
	EventBus.ball_possession_change.connect(self.ball_p)


func ball_p(player: Player):
	if selected_player and not selected_player.is_same(player):
		selected_player.stop()
	print("%s has the ball" % [player.number])
	selected_player = player


func was_long_click() -> bool:
	var result = hold_counter >= long_click
	hold_counter = 0
	return result


func _process(delta: float) -> void:
	if Input.is_action_pressed("Click"):
		hold_counter += delta

	if hold_counter >= long_click:
		charger.visible = true
		charger.value = clamp(hold_counter / max_long_click * 100, 10, 100.0)
		if selected_player:
			charger.global_position = selected_player.global_position + Vector2(0, 30)

	if Input.is_action_just_released("Reset"):
		ball.stop()
		selected_player.stop()
		ball.position = Vector2(450, 250)
		selected_player.position = Vector2(450, 100)

	if Input.is_action_just_released("Click"):
		charger.visible = false
		charger.value = 0
		var held_counter = hold_counter
		if not was_long_click() and selected_player:
			move_action()
		else:
			var t: float = clamp(held_counter / max_long_click, 0.0, 1.0)
			var force: float = lerp(0.1, 1.0, t)
			selected_player.shoot(force)


func move_action():
	var pos = get_global_mouse_position()
	selected_player.select_target(pos)
	var t = TargetIndicator.new()
	t.draw(pos)
	add_child(t)
