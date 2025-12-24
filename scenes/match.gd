extends Node2D

@onready var selected_player: Player = $Home/Player
@onready var ball: Node2D = $Ball
#@onready var camera:Camera2D = $MainCamera;
var hold_counter: float = 0
@export var long_click: float = .40


func was_long_click() -> bool:
	var result = hold_counter >= long_click
	hold_counter = 0
	return result


func _process(delta: float) -> void:
	if Input.is_action_pressed("Click"):
		hold_counter += delta

	if Input.is_action_just_released("Reset"):
		ball.stop()
		selected_player.stop()
		ball.position = Vector2(450, 250)
		selected_player.position = Vector2(450, 100)

	if Input.is_action_just_released("Click"):
		if not was_long_click() and selected_player:
			move_action()
		else:
			print("long click")
			selected_player.shoot()


func move_action():
	var pos = get_global_mouse_position()
	selected_player.select_target(pos)
	var t = TargetIndicator.new()
	t.draw(pos)
	add_child(t)
