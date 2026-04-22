extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass


func physics_update(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	player.move_player(delta, input_dir, player.player_res.move_speed if !player.is_crouching else player.player_res.crouch_speed)
	
	if Input.is_action_pressed("climb_action") and player.climbing_movement.check_can_climb():
		finished.emit(CLIMBING)
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_pressed("move_forward") and Input.is_action_pressed("sprint") and !player.is_crouching:
		finished.emit(SPRINTING)
	elif Input.is_action_just_pressed("jump") or (player.player_res.auto_bhop and Input.is_action_pressed("jump")):
		finished.emit(JUMPING)
	elif is_equal_approx(input_dir.x, 0.0) && is_equal_approx(input_dir.y, 0.0):
		finished.emit(IDLE)
