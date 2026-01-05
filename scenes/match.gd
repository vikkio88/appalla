extends Node2D

const CENTER = Vector2(607, 355)

@onready var selected_player: Player
@onready var ball: Node2D = $Ball
@onready var charger: ProgressBar = $charger
@onready var pitch_sides = {
	Enums.TeamSide.Home: $Home.get_children(), Enums.TeamSide.Away: $Away.get_children()
}
@onready var camera: Camera2D = $MainCamera
var hold_counter: float = 0
@export var long_click: float = .20
@export var max_long_click: float = 0.70
var switched_player = false


func _ready() -> void:
	EventBus.ball_possession_change.connect(self.ball_possession_changed)
	EventBus.clicked_player.connect(self.player_was_clicked)
	EventBus.scored_away_goal.connect(func(player: Player): goal(player, Enums.TeamSide.Away))
	EventBus.scored_home_goal.connect(func(player: Player): goal(player, Enums.TeamSide.Home))
	select_player($"Home/8" as Player)


func goal(player: Player, side: Enums.TeamSide):
	print_debug("goal! side: %s player: %s" % [side, player.number])
	ball.global_position = CENTER

func closest_player(players: Array, ball_position: Vector2) -> Player:
	var closest: Player = null
	var closest_dist := INF

	for pl: Player in players:
		if pl.is_same(selected_player):
			continue
		var dist := pl.global_position.distance_squared_to(ball_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = pl
	return closest

func select_next_player():
	var players = pitch_sides[MatchState.user_side] as Array[Player]
	var ball_position: Vector2 = ball.global_position
	select_player(closest_player(players, ball_position))


func select_player(player: Player):
	if selected_player:
		selected_player.is_selected = false
	selected_player = player
	player.is_selected = true


func player_was_clicked(player: Player):
	print("clicked %s" % player.number)
	if selected_player and selected_player.has_ball():
		return
	switched_player = true
	select_player(player)


func ball_possession_changed(player: Player):
	if selected_player and not selected_player.is_same(player):
		selected_player.stop()
	print("%s has the ball" % [player.number])
	select_player(player)
	MatchState.ball_owner = player


func was_long_click() -> bool:
	var result = hold_counter >= long_click
	hold_counter = 0
	return result


func is_trying_to_shoot() -> bool:
	return hold_counter >= long_click and can_shoot()


func can_shoot() -> bool:
	return selected_player and selected_player.has_ball() and not switched_player


func _process(delta: float) -> void:
	if Input.is_action_pressed("Click"):
		hold_counter += delta

	if Input.is_action_just_released("S") and selected_player:
		if not selected_player.has_ball():
			select_next_player()

	if Input.is_action_just_released("Reset"):
		ball.stop()
		selected_player.stop()
		ball.position = Vector2(450, 250)
		selected_player.position = Vector2(450, 100)

	if is_trying_to_shoot():
		charger.visible = true
		charger.value = clamp(hold_counter / max_long_click * 100, 10, 100.0)
		if selected_player:
			charger.global_position = selected_player.global_position + Vector2(0, 30)

	if Input.is_action_just_released("Click"):
		if switched_player:
			switched_player = false
			return
		charger.visible = false
		charger.value = 0
		var held_counter = hold_counter
		var was_long = was_long_click()
		if (not was_long and selected_player) or (was_long and not can_shoot()):
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

var previous_chaser: Player
func _on_tick_timeout() -> void:
	var ball_pos = ball.global_position
	MatchState.ball_position = ball_pos
	#var home = closest_player(pitch_sides[Enums.TeamSide.Home], ball_pos)
	#if previous_chaser and home.is_same(previous_chaser):
		#return
	#if home and not home.is_selected:
		#if previous_chaser:
			#previous_chaser.decision = Ai.Decision.Wait
			#previous_chaser.stop()
		#previous_chaser = home
		#home.decision = Ai.Decision.ChaseBall
		#home.target = ball_pos
	
