extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass


func physics_update(delta: float) -> void:
	if !player.is_multiplayer_authority() && player.is_multiplayer: return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var floor_angle := player.get_floor_angle()
	var slide_dir: Vector2 = Vector2(input_dir.x, 0)
	if rad_to_deg(floor_angle) > player.player_res.slide_threshold:
		slide_dir = Vector2(input_dir.x, -1 * floor_angle)
	player.slide_player(delta, slide_dir, player.player_res.sprint_speed)
	
	if Input.is_action_pressed("climb_action") and player.check_can_climb():
		finished.emit(CLIMBING)
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump") or (player.player_res.auto_bhop and Input.is_action_pressed("jump")):
		finished.emit(JUMPING)
	elif (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_forward" ) or Input.is_action_pressed("move_back")) && (player.velocity.length() < 1.0 or !player.is_crouching):
		finished.emit(WALKING)
	elif (is_equal_approx(input_dir.x, 0.0) && is_equal_approx(input_dir.y, 0.0) && !player.is_crouching):
		finished.emit(IDLE)
