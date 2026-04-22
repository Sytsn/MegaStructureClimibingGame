class_name BasicMovement extends Node


@export var parent: Player


func stop_parent(delta: float):
	var prev_velocity := parent.velocity
	
	parent.velocity.y += parent.player_res.gravity * delta
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.player_res.move_speed)
	parent.velocity.z = move_toward(parent.velocity.z, 0, parent.player_res.move_speed)
	parent.move_and_slide()
	#climbing_ray_look_at()
	
	var acceleration := (parent.velocity - prev_velocity) / delta
	if parent.player_settings_res.camera_lean_enabled:
		parent.camera_lean.update_lean(delta, acceleration, Vector3.UP)


func air_move_parent(delta: float, input_dir: Vector2):
	var prev_velocity := parent.velocity
	
	parent.velocity.y += parent.player_res.gravity * delta
	var wish_dir = parent.neck.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	
	var cur_speed_in_wish_dir = parent.velocity.dot(wish_dir)
	var capped_speed = min((parent.player_res.air_move_speed * wish_dir).length(), parent.player_res.air_cap)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = parent.player_res.air_accel * parent.player_res.air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		parent.velocity += accel_speed * wish_dir
	
	parent.move_and_slide()
	
	var acceleration := (parent.velocity - prev_velocity) / delta
	if parent.player_settings_res.camera_lean_enabled:
		parent.camera_lean.update_lean(delta, acceleration, Vector3.UP)


func move_parent(delta: float, input_dir: Vector2, speed: float):
	var prev_velocity := parent.velocity
	
	var wish_dir = parent.neck.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	var cur_speed_in_wish_dir = parent.velocity.dot(wish_dir)
	var add_speed_till_cap = speed - cur_speed_in_wish_dir

	if add_speed_till_cap > 0:
		var accel_speed = parent.player_res.air_accel * delta * speed
		accel_speed = min(accel_speed, add_speed_till_cap)
		parent.velocity += accel_speed * wish_dir

	var control = max(parent.velocity.length(), parent.player_res.ground_decel)
	var drop = control * parent.player_res.ground_friction * delta
	var new_speed = max(parent.velocity.length() - drop, 0.0)
	if parent.velocity.length() > 0:
		new_speed /= parent.velocity.length()
	parent.velocity *= new_speed
	
	parent.move_and_slide()
	
	var acceleration := (parent.velocity - prev_velocity) / delta
	if parent.player_settings_res.camera_lean_enabled:
		parent.camera_lean.update_lean(delta, acceleration, Vector3.UP)
