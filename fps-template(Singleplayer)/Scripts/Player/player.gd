class_name Player extends CharacterBody3D


@export var player_res: PlayerRes
@export var player_settings_res: PlayerSettingsRes
@export var neck: Node3D
@export var camera: Camera3D
@export var collider: CollisionShape3D
@export var is_multiplayer: bool = true
@export var crouch_shape_cast: ShapeCast3D
@export var health_res: HealthRes
@export var player_aim_ray: RayCast3D
@export var camera_spring: CameraSpring
@export var camera_lean: CameraLean
@export var fps_arms: FPSArms
@export var interact_ray: RayCast3D

@export_category("Climbing Rays")
@export var climbing_ray: RayCast3D
@export var left_right_container: Node3D
var low_climbing_rays_array: Array[RayCast3D]
var mid_climbing_rays_array: Array[RayCast3D]
var high_climbing_rays_array: Array[RayCast3D]
var left_climbing_rays_array: Array[RayCast3D]
var right_climbing_rays_array: Array[RayCast3D]


@export_category("MovementScripts")
@export var basic_movement: BasicMovement
@export var climbing_pivot: Node3D
var climbing_movement: ClimbingMovement
var has_climbing_upgrade: bool = false

var health: Health
var animation_player: AnimationPlayer

var is_paused = false
var is_crouching = false
var exiting_crouching = false
var is_dead = false
var cur_area_interactable = null
var cur_interactable = null


func _ready() -> void:
	setup_player()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	interactable()
	if Input.is_action_just_pressed("interact"):
		if cur_interactable:
			print("1")
			cur_interactable.interact()
		elif cur_area_interactable:
			print("2")
			cur_area_interactable.interact()
		else:
			print("3")
			print(cur_interactable)
			print(cur_area_interactable)


#region Setup


func setup_player():
	health_setup()
	camera_setup()
	climbing_rays_setup()
	fps_arms_setup()


func health_setup():
	health = Health.new(health_res.max_health, health_res.min_health, health_res.heal_rate, health_res.heal_rate)
	health.dead.connect(_on_death)


func camera_setup():
	if !camera:
		print("No camera set")
		return
	camera.position = player_res.camera_pos


func fps_arms_setup():
	pass
	#fps_arms.global_position = camera.global_position
	#animation_player = fps_arms.find_child("AnimationPlayer")


func climbing_movement_setup(climbing_script: ClimbingMovement):
	climbing_movement = climbing_script
	climbing_movement.player = self


func climbing_rays_setup():
	climbing_ray.target_position = global_transform.basis * player_res.climbing_ray_target_pos
	var low = $ClimbingPivot/ClimbingRays/Low.get_children()
	var mid = $ClimbingPivot/ClimbingRays/Mid.get_children()
	var high = $ClimbingPivot/ClimbingRays/High.get_children()
	var left = $ClimbingPivot/ClimbingRays/LeftRightContainer/Left.get_children()
	var right = $ClimbingPivot/ClimbingRays/LeftRightContainer/Right.get_children()
	
	var ray_angle = 0
	for child in low:
		if child is RayCast3D:
			low_climbing_rays_array.append(child)
			child.rotation.y = deg_to_rad(ray_angle)
			child.target_position = player_res.climbing_ray_target_pos
			ray_angle += 360 / low.size()
	ray_angle = 0
	for child in mid:
		if child is RayCast3D:
			mid_climbing_rays_array.append(child)
			child.rotation.y = deg_to_rad(ray_angle)
			child.target_position = player_res.climbing_ray_target_pos
			ray_angle += 360 / mid.size()
	ray_angle = 0
	for child in high:
		if child is RayCast3D:
			high_climbing_rays_array.append(child)
			child.rotation.y = deg_to_rad(ray_angle)
			child.target_position = player_res.climbing_ray_target_pos
			ray_angle += 360 / high.size()
	for child in left:
		if child is RayCast3D:
			left_climbing_rays_array.append(child)
			child.target_position = player_res.climbing_ray_target_pos
	for child in right:
		if child is RayCast3D:
			right_climbing_rays_array.append(child)
			child.target_position = player_res.climbing_ray_target_pos

#endregion


#region Player Movement

func move_player(delta: float, input_dir: Vector2, speed: float):
	if basic_movement:
		basic_movement.move_parent(delta, input_dir, speed)


func air_move_player(delta: float, input_dir: Vector2):
	if basic_movement:
		basic_movement.air_move_parent(delta, input_dir)


func slide_player(delta: float, input_dir: Vector2, speed: float):
	if basic_movement:
		basic_movement.stop_parent(delta)


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
	velocity.y += -50.0
	move_and_slide()


func  enter_crouch_air():
	collider.scale.y = collider.scale.y / 2


func exit_crouch():
	is_crouching = false
	collider.scale.y = collider.scale.y * 2
	exiting_crouching = false


#endregion


#region FPS Arms


func follow_camera():
	#fps_arms.rotation = neck.rotation + Vector3(deg_to_rad(player_res.fps_arms_rot.x), deg_to_rad(player_res.fps_arms_rot.y), deg_to_rad(player_res.fps_arms_rot.z))
	pass


#endregion


func interactable():
	if interact_ray.is_colliding() and cur_interactable == null:
		var res = interact_ray.get_collider()
		if res is Node3D:
			cur_interactable = res.get_parent()
			print(cur_interactable)
		if res is StaticBody3D:
			cur_interactable = res
	elif !interact_ray.is_colliding() and cur_interactable != null:
		cur_interactable = null


func check_climbing_state_enter():
	if Input.is_action_pressed("climb_action") and check_has_climbing_upgrade():
		if climbing_movement.check_can_climb():
			return true
	return false


func check_has_climbing_upgrade():
	if climbing_movement:
		return true
	return false


func _on_death():
	is_dead = true
