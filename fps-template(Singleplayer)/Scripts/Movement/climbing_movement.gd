class_name ClimbingMovement extends Node


var player: Player

var wall_normal: Vector3
var wall_hit: Vector3
var wall_up: Vector3

var is_low_colliding: bool 
var is_high_colliding: bool

var clamber_tween: Tween
var clamber_tween2: Tween

var is_clambering: bool = false

func check_can_climb():
	if player.climbing_ray.is_colliding():
		return true
	return false


func set_climbing_offset():
	set_average_normal()
	var wall_offset := 1.0
	var target_point = wall_hit + (wall_normal.normalized() * wall_offset)
	if is_nan(target_point.x) or is_nan(target_point.y) or is_nan(target_point.z):
		print("Target is Nan")
		return
	player.global_position.x = target_point.x
	player.global_position.z = target_point.z


func exit_climb():
	player.climbing_pivot.global_transform.basis = player.global_transform.basis


func climb_move():
	var can_climb = check_climbing_bounds()
	var forward: float
	var backward: float
	var left: float
	var right: float
	
	if can_climb["high"] and !player.is_on_ceiling(): 
		check_clamber()
		forward = Input.get_action_strength("move_forward")
	if can_climb["low"] and !player.is_on_floor():
		backward = Input.get_action_strength("move_back")
	if can_climb["left"]:
		left = Input.get_action_strength("move_left")
	if can_climb["right"]:
		right = Input.get_action_strength("move_right")
	
	var wall_right = Vector3.UP.cross(wall_normal.normalized()).normalized()
	
	var input_forward = forward - backward
	var input_right   = right   - left
	
	var move_dir = (wall_up * input_forward) + (wall_right * input_right)
	var climb_speed = 5.0
	
	if move_dir.length() > 0.001:
		move_dir = move_dir.normalized() * climb_speed
	else:
		move_dir = Vector3.ZERO
	
	player.velocity = move_dir 
	player.move_and_slide()


func update_wall_up():
	var world_up = Vector3.UP
	wall_up = (world_up - world_up.project(wall_normal.normalized())).normalized()


func set_average_normal():
	is_low_colliding = false
	is_high_colliding = false
	var total_normal := Vector3.ZERO
	var total_hit_points := Vector3.ZERO 
	var total_hits := 0
	
	for ray in player.mid_climbing_rays_array:
		if ray:
			if ray.is_colliding():
				var cur_normal = ray.get_collision_normal()
				var cur_hit = ray.get_collision_point()
				total_normal += cur_normal
				total_hit_points += cur_hit
				total_hits += 1
	
	if total_hits == 0:
		# Prevent division by zero
		is_low_colliding = false
		is_high_colliding = false
		return 
	
	var average_normal = total_normal / total_hits
	var average_hit = total_hit_points / total_hits
	wall_normal = average_normal
	wall_hit = average_hit
	set_left_right_container()
	update_wall_up()


func set_left_right_container():
	var basis = Basis().looking_at(-wall_normal, wall_up).orthonormalized()
	player.left_right_container.global_transform.basis = basis


func update_climbing_orientation(enter_climb: bool = false) -> void:
	if wall_up == Vector3.UP:
		return
	var tilt_basis = Basis().looking_at(-wall_normal, wall_up).orthonormalized()
	player.climbing_pivot.global_transform.basis = tilt_basis
	if enter_climb:
		player.neck.rotation = Vector3.ZERO


func check_climbing_bounds():
	var is_low_colliding: bool = false
	var is_high_colliding: bool = false
	var is_left_colliding: bool = false
	var is_right_colliding: bool = false
	
	for ray in player.low_climbing_rays_array:
		if ray:
			if ray.is_colliding():
				is_low_colliding = true
	for ray in player.high_climbing_rays_array:
		if ray:
			if ray.is_colliding():
				is_high_colliding = true
	for ray in player.left_climbing_rays_array:
		if ray:
			if ray.is_colliding():
				is_left_colliding = true
	for ray in player.right_climbing_rays_array:
		if ray:
			if ray.is_colliding():
				is_right_colliding = true
	return {
		"low": is_low_colliding,
		"high": is_high_colliding,
		"left": is_left_colliding,
		"right": is_right_colliding
	}


func check_clamber():
	var can_climb = check_climbing_bounds()
	if !can_climb["high"] and !player.is_on_ceiling():
		player.clamber_prompt.emit(true)
	else:
		player.clamber_prompt.emit(false)


func clamber():
	is_clambering = true
	if clamber_tween and clamber_tween.is_running():
		clamber_tween.kill()

	var start_pos = player.global_position
	var up_pos = start_pos + wall_up * player.player_res.player_height
	var forward_pos = up_pos + (-wall_normal.normalized() * 1.0)

	clamber_tween = create_tween()
	clamber_tween.tween_property(player, "global_position", up_pos, 0.3)
	clamber_tween.tween_property(player, "global_position", forward_pos, 0.3)
	is_clambering = false
	return true
