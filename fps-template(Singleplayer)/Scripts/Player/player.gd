class_name Player extends CharacterBody3D


@export var player_res: PlayerRes
@export var player_settings_res: PlayerSettingsRes
@export var neck: Node3D
@export var camera: Camera3D
@export var collider: CollisionShape3D
@export var mesh: MeshInstance3D
@export var is_multiplayer: bool = true
@export var crouch_shape_cast: ShapeCast3D
@export var health_res: HealthRes
@export var player_aim_ray: RayCast3D
@export var camera_spring: CameraSpring
@export var camera_lean: CameraLean
@export var fps_arms: Node3D

@export_category("Climbing Rays")
@export var climbing_ray: RayCast3D
@export var low_climbing_rays_array: Array[RayCast3D]
@export var mid_climbing_rays_array: Array[RayCast3D]
@export var high_climbing_rays_array: Array[RayCast3D]

@export_category("MovementScripts")
@export var basic_movement: BasicMovement
@export var climbing_movement: ClimbingMovement


var health: Health
var animation_player: AnimationPlayer

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
	animation_player = fps_arms.find_child("AnimationPlayer")


func climbing_rays_setup():
	climbing_ray.target_position = global_transform.basis * player_res.climbing_ray_target_pos

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

# This is broken when climbing in a NON -Z facing direction. This is probably because how I am doing this, so before I move on I will blow this up. 
# But I am going to be using the array of rays now, I will need to update them to be ALL AROUND the player not just forward. WE DO NOT WANT TO ROTATE THE PLAYER ALONG THE Y AXIS
# The player can tilt but should not spin, that causes issues.
func enter_climb():
	if climbing_movement:
		climbing_movement.enter_climb()


func set_climbing_offset():
	if climbing_movement:
		climbing_movement.set_climbing_offset()


func climb_move(delta: float) -> void:
	if climbing_movement:
		climbing_movement.climb_move(delta)


func exit_climb():
	if climbing_movement:
		climbing_movement.exit_climb()


#endregion


func _on_death():
	is_dead = true
