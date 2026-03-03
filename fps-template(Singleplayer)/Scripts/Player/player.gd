class_name Player extends CharacterBody3D


@export var player_res: PlayerRes
@export var player_settings_res: PlayerSettings
@export var neck: Node3D
@export var camera: Camera3D
@export var collider: CollisionShape3D
@export var mesh: MeshInstance3D
@export var is_multiplayer: bool = true
@export var crouch_shape_cast: ShapeCast3D
@export var health_res: HealthRes
@export var player_aim_ray: RayCast3D
@export var climbing_ray: RayCast3D
@export var camera_spring: CameraSpring
@export var camera_lean: CameraLean

var health: Health
var is_paused = false
var is_crouching = false
var exiting_crouching = false
var is_dead = false


func _ready() -> void:
	setup_player()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


#region Setup


func setup_player():
	health_setup()
	camera_setup()
	climbing_ray_setup()


func health_setup():
	health = Health.new(health_res.max_health, health_res.min_health, health_res.heal_rate, health_res.heal_rate)
	health.dead.connect(_on_death)


func camera_setup():
	if !camera:
		print("No camera set")
		return
	camera.position = player_res.camera_pos


func climbing_ray_setup():
	climbing_ray.target_position = global_transform.basis * player_res.climbing_ray_target_pos
	climbing_ray.rotation = Vector3.ZERO
	climbing_ray.position = Vector3.ZERO

#endregion


#region Player Movement

func move_player(delta: float, input_dir: Vector2, speed: float):
	var prev_velocity := velocity
	
	var wish_dir = neck.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	var cur_speed_in_wish_dir = velocity.dot(wish_dir)
	var add_speed_till_cap = speed - cur_speed_in_wish_dir

	if add_speed_till_cap > 0:
		var accel_speed = player_res.air_accel * delta * speed
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * wish_dir

	var control = max(velocity.length(), player_res.ground_decel)
	var drop = control * player_res.ground_friction * delta
	var new_speed = max(velocity.length() - drop, 0.0)
	if velocity.length() > 0:
		new_speed /= velocity.length()
	velocity *= new_speed
	
	move_and_slide()
	
	var acceleration := (velocity - prev_velocity) / delta
	if PlayerSettings.player_settings_res.camera_lean_enabled:
		camera_lean.update_lean(delta, acceleration, Vector3.UP)



func air_move_player(delta: float, input_dir: Vector2):
	var prev_velocity := velocity
	
	velocity.y += player_res.gravity * delta
	var wish_dir = neck.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	
	var cur_speed_in_wish_dir = velocity.dot(wish_dir)
	var capped_speed = min((player_res.air_move_speed * wish_dir).length(), player_res.air_cap)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = player_res.air_accel * player_res.air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * wish_dir
	
	move_and_slide()
	
	var acceleration := (velocity - prev_velocity) / delta
	if PlayerSettings.player_settings_res.camera_lean_enabled:
		camera_lean.update_lean(delta, acceleration, Vector3.UP)


func slide_player(delta: float, input_dir: Vector2, speed: float):
	var prev_velocity := velocity
	
	var wish_dir = neck.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	var cur_speed_in_wish_dir = velocity.dot(wish_dir)
	var add_speed_till_cap = speed - cur_speed_in_wish_dir

	if add_speed_till_cap > 0:
		var accel_speed = player_res.slide_accel * delta * speed
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * wish_dir

	var control = max(velocity.length(), player_res.slide_decel) 
	var drop = control * player_res.slide_friction * delta
	var new_speed = max(velocity.length() - drop, 0.0)
	if velocity.length() > 0:
		new_speed /= velocity.length()
	velocity *= new_speed
	
	move_and_slide()
	
	var acceleration := (velocity - prev_velocity) / delta
	if PlayerSettings.player_settings_res.camera_lean_enabled:
		camera_lean.update_lean(delta, acceleration, Vector3.UP)


func stop_player(delta: float):
	var prev_velocity := velocity
	
	velocity.y += player_res.gravity * delta
	velocity.x = move_toward(velocity.x, 0, player_res.move_speed)
	velocity.z = move_toward(velocity.z, 0, player_res.move_speed)
	move_and_slide()
	#climbing_ray_look_at()
	
	var acceleration := (velocity - prev_velocity) / delta
	if PlayerSettings.player_settings_res.camera_lean_enabled:
		camera_lean.update_lean(delta, acceleration, Vector3.UP)


#endregion


#region Crouching

func enter_crouch_ground():
	if exiting_crouching:
		return
	is_crouching = true
	collider.scale.y = collider.scale.y / 2
	neck.position.y -=  .6
	velocity.y += -50.0
	move_and_slide()


func  enter_crouch_air():
	collider.scale.y = collider.scale.y / 2
	neck.position.y -=  .6

func exit_crouch():
	is_crouching = false
	collider.scale.y = collider.scale.y * 2
	neck.position.y += .6
	exiting_crouching = false


#endregion


#region Climbing


func check_can_climb():
	if !player_res.climb_abilitity:
		return false
	if !climbing_ray.is_colliding():
		return false
	else:
		return true


func enter_climb():
	var wall = climbing_ray.get_collider()
	var wall_normal = climbing_ray.get_collision_normal()
	var forward = -wall_normal
	forward = forward.normalized()
	
	var basis = Basis()
	basis = basis.looking_at(forward)
	self.basis = basis
	
	climbing_ray.reparent(self)
	return forward


func set_climbing_offset():
	var wall_normal = climbing_ray.get_collision_normal()
	var wall_point = climbing_ray.get_collision_point()
	var to_plane = global_position - wall_point
	var dist = to_plane.dot(wall_normal)
	var correction = (player_res.wall_player_offset - dist) * wall_normal
	global_position += correction


func climb_move(delta: float) -> void:
	# Get input
	var forward = Input.get_action_strength("move_forward")
	var backward = Input.get_action_strength("move_back")
	var left = Input.get_action_strength("move_left")
	var right = Input.get_action_strength("move_right")
	
	if is_on_floor():
		backward = 0.0
	if !climbing_ray.is_colliding():
		forward = 0.0
	
	var input_forward = forward - backward
	var input_right   = right   - left

	# Get wall info
	var wall_normal: Vector3 = climbing_ray.get_collision_normal()
	var v = get_wall_space_vectors(wall_normal)
	var wall_up    = v["up"]
	var wall_right = v["right"]

	# Build desired velocity along the wall
	var climb_speed = player_res.climb_speed
	var move_dir = (wall_up * input_forward) + (wall_right * input_right)

	if move_dir.length() > 0.001:
		move_dir = move_dir.normalized() * climb_speed
	else:
		move_dir = Vector3.ZERO

	velocity = move_dir 
	print(velocity)
	move_and_slide()


func exit_climb():
	rotation = Vector3.ZERO
	climbing_ray.reparent(camera)
	climbing_ray_setup()

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


#endregion


func _on_death():
	is_dead = true
