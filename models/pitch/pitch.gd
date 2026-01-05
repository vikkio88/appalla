extends Node2D


func _on_away_goal_body_entered(body: Node2D) -> void:
	if body is Ball:
		if body.last_touched_by:
			EventBus.scored_away_goal.emit(body.last_touched_by)
		body.stop()


func _on_home_goal_body_entered(body: Node2D) -> void:
	if body is Ball:
		if body.last_touched_by:
			EventBus.scored_home_goal.emit(body.last_touched_by)
		body.stop()
