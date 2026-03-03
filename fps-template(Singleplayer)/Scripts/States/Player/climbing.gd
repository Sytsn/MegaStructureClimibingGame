extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	player.enter_climb()
	player.set_climbing_offset()


func physics_update(delta: float) -> void:
	player.set_climbing_offset()
	player.climb_move(delta)
	
	if Input.is_action_just_released("climb_action"):
		finished.emit(FALLING)
	#if not player.is_on_floor():
		#finished.emit(FALLING)
	#elif Input.is_action_just_pressed("jump") or (player.player_res.auto_bhop and Input.is_action_pressed("jump")):
		#finished.emit(JUMPING)
	#elif Input.is_action_pressed("move_forward") and Input.is_action_pressed("sprint"):
		#finished.emit(SPRINTING)
	#elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward" ) or Input.is_action_pressed("move_back"):
		#finished.emit(WALKING)


func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		player.neck.rotate_y(-event.relative.x * player.player_res.mouse_sens)
		player.camera.rotate_x(-event.relative.y * player.player_res.mouse_sens)
		
		player.camera.rotation.x = clamp(
			player.camera.rotation.x,
			deg_to_rad(-90),
			deg_to_rad(90)
		)
		player.neck.rotation.y = clamp(
			player.neck.rotation.y,
			deg_to_rad(-160),
			deg_to_rad(160)
		)


func exit() -> void:
	player.exit_climb()
