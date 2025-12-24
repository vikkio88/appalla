extends Node2D
class_name TargetIndicator

@export var radius := 20.0
@export var lifetime := .3
@export var color := Color(1, 1, 1, .2)


func draw(pos: Vector2) -> void:
	global_position = pos


func _ready():
	queue_redraw()
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _draw():
	draw_circle(Vector2.ZERO, radius, color)
