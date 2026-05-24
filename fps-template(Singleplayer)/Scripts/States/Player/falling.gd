extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass


func physics_update(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	player.air_move_player(delta, input_dir)

	if player.check_climbing_state_enter():
			finished.emit(CLIMBING)
	if player.is_on_floor():
		if player.velocity.length() > 7.0 && player.is_crouching:
			finished.emit(SLIDING)
		elif is_equal_approx(input_dir.x, 0.0) && is_equal_approx(input_dir.y, 0.0):
			finished.emit(IDLE)
		elif Input.is_action_pressed("move_forward") and Input.is_action_pressed("sprint"):
			finished.emit(SPRINTING)
		elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward" ) or Input.is_action_pressed("move_back"):
			finished.emit(WALKING)
