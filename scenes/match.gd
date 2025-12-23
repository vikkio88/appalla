extends Node2D

@onready var selected_player:Player = $Player;
@onready var ball:Node2D = $Ball;
#@onready var camera:Camera2D = $MainCamera;


func _process(_delta: float) -> void:
	if Input.is_action_just_released("Reset"):
		ball.stop()
		selected_player.stop()
		ball.position = Vector2(450,250)
		selected_player.position = Vector2(450, 100)
	
	if Input.is_action_just_released("Click"):
		var pos =get_global_mouse_position()
		selected_player.select_target(pos)
		var t = TargetIndicator.new();
		t.draw(pos)
		add_child(t)
