extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	player.climbing_movement.set_average_normal()
	player.climbing_movement.set_climbing_offset(true)
	player.climbing_movement.update_climbing_orientation(true)
	player.velocity = Vector3.ZERO
	player.fps_arms.enable_ik()

	print("climbing")


func physics_update(delta: float) -> void:
	player.climbing_movement.set_average_normal()
	player.climbing_movement.update_climbing_orientation()
	player.climbing_movement.climb_move()
	player.climbing_movement.check_clamber()

	
	if Input.is_action_just_pressed("jump") && player.can_clamber:
		finished.emit(CLAMBERING)
	if Input.is_action_just_released("climb_action"):
		finished.emit(IDLE)
	#if not player.is_on_floor():
		#finished.emit(FALLING)
	#elif Input.is_action_just_pressed("jump") or (player.player_res.auto_bhop and Input.is_action_pressed("jump")):
		#finished.emit(JUMPING)d("sprint"):
		#finished.emit(SPRINTING)
	#elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward" ) or Input.is_action_pressed("move_back"):
		#finished.emit(WALKING)


func exit() -> void:
	player.climbing_movement.exit_climb()
	player.clamber_prompt.emit(false)
	player.fps_arms.disable_ik()
	
