extends Node2D

@onready var selected_player:Node2D = $Player;
@onready var ball:Node2D = $Ball;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_just_released("Reset"):
		ball.stop()
		selected_player.stop()
		ball.position = Vector2(450,250)
		selected_player.position = Vector2(450, 100)
	
	if Input.is_action_just_released("Click"):
		selected_player.target = get_global_mouse_position()
