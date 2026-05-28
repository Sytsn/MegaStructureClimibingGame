extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	player.clamber_prompt.emit(false)

func physics_update(delta: float) -> void:
	var res = player.climbing_movement.clamber()
	player.clamber_prompt.emit(false)
	
	finished.emit(IDLE)
	#if not player.is_on_floor():
		#finished.emit(FALLING)
	#elif Input.is_action_just_pressed("jump") or (player.player_res.auto_bhop and Input.is_action_pressed("jump")):
		#finished.emit(JUMPING)d("sprint"):
		#finished.emit(SPRINTING)
	#elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward" ) or Input.is_action_pressed("move_back"):
		#finished.emit(WALKING)

func handle_input(event: InputEvent) -> void:
	pass


func exit() -> void:
	player.climbing_movement.exit_climb()
