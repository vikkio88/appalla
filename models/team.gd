extends Node
class_name Team

@export var side: Enums.TeamSide = Enums.TeamSide.Home

@onready var movement_players = $Players

var is_user_team = false

func get_players()-> Array[Node]:
	return movement_players.get_children()


func closest_player(selected_player: Player, ball_position: Vector2) -> Player:
	var closest: Player = null
	var closest_dist := INF
	var players = get_players();

	for pl: Player in players:
		if pl.is_same(selected_player):
			continue
		var dist := pl.global_position.distance_squared_to(ball_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = pl
	return closest


func _ready() -> void:
	is_user_team = MatchState.user_side == side
	
