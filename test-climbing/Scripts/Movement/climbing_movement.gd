class_name ClimbingMovement extends Node


@export var player: Player

var wall_normal: Vector3
var wall_hit: Vector3
var wall_up: Vector3


func check_can_climb():
	if player.climbing_ray.is_colliding():
		return true
	return false


func set_climbing_offset():
	set_average_normal()
	var wall_offset := 1.0
	var target_point = wall_hit + (wall_normal.normalized() * wall_offset)
	if is_nan(target_point.x) or is_nan(target_point.y) or is_nan(target_point.z):
		print("test")
		return
	player.global_position = target_point


func exit_climb():
	player.climbing_pivot.global_transform.basis = player.global_transform.basis


func climb_move():
	var forward = Input.get_action_strength("move_forward")
	var backward = Input.get_action_strength("move_back")
	var left = Input.get_action_strength("move_left")
	var right = Input.get_action_strength("move_right")
	
	set_average_normal()
	update_climbing_orientation()
	
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
	var total_normal := Vector3.ZERO
	var total_hit_points := Vector3.ZERO 
	var total_hits := 0
	for ray in player.climbing_rays:
		if ray:
			if ray.is_colliding():
				var cur_normal = ray.get_collision_normal()
				var cur_hit = ray.get_collision_point()
				total_normal += cur_normal
				total_hit_points += cur_hit
				total_hits += 1
	var average_normal = total_normal / total_hits
	var average_hit = total_hit_points / total_hits
	wall_normal = average_normal
	wall_hit = average_hit
	update_wall_up()


func update_climbing_orientation() -> void:
	var tilt_basis = Basis().looking_at(-wall_normal, wall_up).orthonormalized()
	player.climbing_pivot.global_transform.basis = tilt_basis
