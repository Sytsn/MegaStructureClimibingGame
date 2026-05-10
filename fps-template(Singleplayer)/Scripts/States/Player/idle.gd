extends PlayerState

var animation: Animation

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	#animation = player.animation_player.get_animation("Idle")
	#animation.loop_mode = Animation.LOOP_LINEAR
	#player.animation_player.play("Idle")

func physics_update(delta: float) -> void:
	player.stop_player(delta)

	if not player.is_on_floor():
		finished.emit(FALLING)
	if player.check_climbing_state_enter():
			finished.emit(CLIMBING)
	if Input.is_action_just_pressed("jump") or (player.player_res.auto_bhop and Input.is_action_pressed("jump")):
		finished.emit(JUMPING)
	if Input.is_action_pressed("move_forward") and Input.is_action_pressed("sprint"):
		finished.emit(SPRINTING)
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward" ) or Input.is_action_pressed("move_back"):
		finished.emit(WALKING)


#func exit() -> void:
	#animation.loop_mode = Animation.LOOP_NONE
	#player.animation_player.stop()
