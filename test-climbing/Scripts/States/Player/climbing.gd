extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	player.climbing_movement.set_average_normal()
	player.climbing_movement.set_climbing_offset()
	player.velocity = Vector3.ZERO


func physics_update(delta: float) -> void:
	
	player.climbing_movement.climb_move()
	
	if Input.is_action_just_released("climb_action"):
		finished.emit(IDLE)
	#if not player.is_on_floor():
		#finished.emit(FALLING)
	#elif Input.is_action_just_pressed("jump") or (player.player_res.auto_bhop and Input.is_action_pressed("jump")):
		#finished.emit(JUMPING)d("sprint"):
		#finished.emit(SPRINTING)
	#elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward" ) or Input.is_action_pressed("move_back"):
		#finished.emit(WALKING)
