class_name ClimbingMovement extends Node


@export var parent: Player


func check_can_climb():
	if !parent.player_res.climb_abilitity:
		return false
	if !parent.climbing_ray.is_colliding():
		return false
	else:
		return true

# This is broken when climbing in a NON -Z facing direction. This is probably because how I am doing this, so before I move on I will blow this up. 
# But I am going to be using the array of rays now, I will need to update them to be ALL AROUND the parent not just forward. WE DO NOT WANT TO ROTATE THE parent ALONG THE Y AXIS
# The parent can tilt but should not spin, that causes issues.
func enter_climb():
	var wall = parent.climbing_ray.get_collider()
	var wall_normal = parent.climbing_ray.get_collision_normal()
	var forward = -wall_normal
	forward = forward.normalized()
	
	var basis = Basis()
	basis = basis.looking_at(forward)
	parent.basis = basis
	
	parent.climbing_ray.reparent(parent)
	return forward


func set_climbing_offset():
	var wall_normal = parent.climbing_ray.get_collision_normal()
	var wall_point = parent.climbing_ray.get_collision_point()
	var to_plane = parent.global_position - wall_point
	var dist = to_plane.dot(wall_normal)
	var correction = (parent.player_res.wall_player_offset - dist) * wall_normal
	parent.global_position += correction


func climb_move(delta: float) -> void:
	# Get input
	var forward = Input.get_action_strength("move_forward")
	var backward = Input.get_action_strength("move_back")
	var left = Input.get_action_strength("move_left")
	var right = Input.get_action_strength("move_right")
	
	if parent.is_on_floor():
		backward = 0.0
	if !parent.climbing_ray.is_colliding():
		forward = 0.0
	
	var input_forward = forward - backward
	var input_right   = right   - left

	# Get wall info
	var wall_normal: Vector3 = get_average_normal()
	var v = get_wall_space_vectors(wall_normal)
	var wall_up    = v["up"]
	var wall_right = v["right"]

	# Build desired parent.velocity along the wall
	var climb_speed = parent.player_res.climb_speed
	var move_dir = (wall_up * input_forward) + (wall_right * input_right)

	if move_dir.length() > 0.001:
		move_dir = move_dir.normalized() * climb_speed
	else:
		move_dir = Vector3.ZERO

	parent.velocity = move_dir 
	print(parent.velocity)
	parent.move_and_slide()


func get_average_normal() -> Vector3:
	var total_normals = Vector3.ZERO
	var total_hits = 0
	
	for ray in parent.low_climbing_rays_array:
		if ray.is_colliding():
			total_normals += ray.get_collision_normal()
			total_hits += 1
	for ray in parent.mid_climbing_rays_array:
		if ray.is_colliding():
			total_normals += ray.get_collision_normal()
			total_hits += 1
	for ray in parent.high_climbing_rays_array:
		if ray.is_colliding():
			total_normals += ray.get_collision_normal()
			total_hits += 1
	
	var average_normal = total_normals / total_hits
	return average_normal


func exit_climb():
	parent.rotation = Vector3.ZERO
	parent.climbing_ray.reparent(parent.camera)
	parent.climbing_ray.rotation = Vector3.ZERO
	parent.climbing_ray.position = Vector3.ZERO


func get_wall_space_vectors(wall_normal: Vector3) -> Dictionary:
	# Wall normal points out of the wall
	var n = wall_normal.normalized()

	# Choose a reference up. If the wall is near vertical, global up works.
	var world_up = Vector3.UP

	# "Up" along the wall: remove the component of world_up that points into the wall
	# This gives a direction that is parallel to the wall surface.
	var wall_up = (world_up - world_up.project(n)).normalized()

	# "Right" along the wall (sideways tangent)
	var wall_right = wall_up.cross(n).normalized()

	return {
		"up": wall_up,
		"right": wall_right,
		"normal": n,
	}
