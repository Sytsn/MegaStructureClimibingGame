extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	#player.animation_player.play("idle")

func physics_update(delta: float) -> void:
	player.stop_player(delta)

	if not player.is_on_floor():
		finished.emit(FALLING)
	if Input.is_action_pressed("climb_action") and player.check_can_climb():
		finished.emit(CLIMBING)
	elif Input.is_action_just_pressed("jump") or (player.player_res.auto_bhop and Input.is_action_pressed("jump")):
		finished.emit(JUMPING)
	elif Input.is_action_pressed("move_forward") and Input.is_action_pressed("sprint"):
		finished.emit(SPRINTING)
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward" ) or Input.is_action_pressed("move_back"):
		finished.emit(WALKING)
