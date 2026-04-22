extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = player.player_res.jump_impulse
	#player.animation_player.play("jump")

func physics_update(delta: float) -> void:
	if !player.is_multiplayer_authority() && player.is_multiplayer: return

	if player.velocity.y >= 0:
		finished.emit(FALLING)
	if Input.is_action_pressed("climb_action") and player.climbing_movement.check_can_climb():
		finished.emit(CLIMBING)
