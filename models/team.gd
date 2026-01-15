extends Node
class_name Team

@export var side: Enums.TeamSide = Enums.TeamSide.Home

@onready var movement_players = $Players

var chaser: Player
var is_user_team = false

func get_players()-> Array[Node]:
	return movement_players.get_children()

func closest_player(selected_player: Player, ball_position: Vector2) -> Player:
	var closest: Player = null
	var closest_dist := INF
	var players = get_players();

	for pl: Player in players:
		if pl.is_selected:
			continue
		if selected_player and pl.is_same(selected_player):
			continue
		var dist := pl.global_position.distance_squared_to(ball_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = pl
	return closest


func _ready() -> void:
	is_user_team = MatchState.user_side == side
	


func _on_tick_timeout() -> void:
	if not MatchState.ball_owner and not chaser:
		var pl = closest_player(null, MatchState.ball_position)
		pl.chase(MatchState.ball_position)
		chaser = pl
		return
	#var decision = MatchState.ball_position.x > Vars.CENTER.x  attack or defend then reset chaser
	chaser = null
	if MatchState.ball_position.x > Vars.CENTER.x:
		for pl in get_players() as Array[Player]:
			if pl.is_selected:
				continue
			pl.attack()
	else:
		for pl in get_players() as Array[Player]:
			if pl.is_selected:
				continue
			pl.defend()
