class_name PlayerState extends State

const IDLE = "Idle"
const WALKING = "Walking"
const SPRINTING = "Sprinting"
const JUMPING = "Jumping"
const FALLING = "Falling"
const SLIDING = "Sliding"
const CLIMBING = "Climbing"

var player: Player

var mouse_look := Vector2.ZERO
@export var look_sens_mouse := 0.002
@export var look_sens_pad := .01

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")


func update(delta: float) -> void:
	crouch_inputs()
	ui_inputs()
	update_look(delta)


func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_look += event.relative

	
	if !player.is_multiplayer_authority() && player.is_multiplayer: return

	if event is InputEventMouseMotion:
		player.neck.rotate_y(-event.relative.x * player.player_res.mouse_sens)
		player.camera.rotate_x(-event.relative.y * player.player_res.mouse_sens)
		
		player.camera.rotation.x = clamp(
		player.camera.rotation.x,
		deg_to_rad(-90),
		deg_to_rad(90)
	)


func crouch_inputs():
	if !player.is_multiplayer_authority() && player.is_multiplayer: return

	if player.exiting_crouching and !player.crouch_shape_cast.is_colliding():
		player.exit_crouch()
	if Input.is_action_just_pressed("crouch") && player.is_on_floor():
		player.enter_crouch_ground()
	if Input.is_action_just_pressed("crouch") && !player.is_crouching:
		player.enter_crouch_air()
	if Input.is_action_just_released("crouch"):
		player.exiting_crouching = true



func ui_inputs():
	if Input.is_action_just_released("ui_cancel") and not player.is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		player.is_paused = true
		#get_tree().paused = true
	elif Input.is_action_just_released("ui_cancel") and player.is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player.is_paused = false
		get_tree().paused = false


func update_look(delta: float) -> void:
	if !player.is_multiplayer_authority() && player.is_multiplayer:
		return

	var stick_look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	var look := Vector2(
		mouse_look.x * look_sens_mouse + stick_look.x * look_sens_pad,
		mouse_look.y * look_sens_mouse + stick_look.y * look_sens_pad
	)

	player.neck.rotate_y(-look.x)
	player.camera.rotate_x(-look.y)
	player.camera.rotation.x = clamp(player.camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	mouse_look = Vector2.ZERO
