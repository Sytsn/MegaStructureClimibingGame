class_name Player extends CharacterBody3D


@export var player_res: PlayerRes
@export var neck: Node3D
@export var camera: Camera3D
@export var collider: CollisionShape3D
@export var mesh: MeshInstance3D
@export var is_multiplayer: bool = true
@export var crouch_shape_cast: ShapeCast3D
@export var health_res: HealthRes
@export var player_aim_ray: RayCast3D
@export var climbing_ray: RayCast3D


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


func health_setup():
	health = Health.new(health_res.max_health, health_res.min_health, health_res.heal_rate, health_res.heal_rate)
	health.dead.connect(_on_death)


func camera_setup():
	if !camera:
		print("No camera set")
		return
	camera.position = player_res.camera_pos


#endregion


#region Player Movement

func move_player(delta: float, input_dir: Vector2, speed: float):
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


func air_move_player(delta: float, input_dir: Vector2):
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


func slide_player(delta: float, input_dir: Vector2, speed: float):
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


func stop_player(delta: float):
	velocity.y += player_res.gravity * delta
	velocity.x = move_toward(velocity.x, 0, player_res.move_speed)
	velocity.z = move_toward(velocity.z, 0, player_res.move_speed)
	move_and_slide()


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
	print(rotation)
	print(wall_normal)
	var forward = -wall_normal
	forward = forward.normalized()

	var basis = Basis()
	basis = basis.looking_at(forward)
	self.basis = basis
	return forward

func climb_move(delta: float) -> void:
	# Get input
	var input_forward = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var input_right   = Input.get_action_strength("move_right")   - Input.get_action_strength("move_left")

	# Get wall info
	var wall_normal: Vector3 = climbing_ray.get_collision_normal()
	var v = get_wall_space_vectors(wall_normal)
	var wall_up    = v["up"]
	var wall_right = v["right"]

	# Build desired velocity along the wall
	var climb_speed = 4.0
	var move_dir = (wall_up * input_forward) + (wall_right * input_right)

	if move_dir.length() > 0.001:
		move_dir = move_dir.normalized() * climb_speed
	else:
		move_dir = Vector3.ZERO

	# Optional: keep a bit of stick-to-wall force so you don’t detach
	var stick_force = -wall_normal * 5.0

	velocity = move_dir + stick_force
	move_and_slide()


func exit_climb():
	rotation = Vector3.ZERO


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
