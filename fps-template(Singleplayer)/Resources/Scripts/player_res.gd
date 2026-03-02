class_name PlayerRes extends Resource

@export var camera_pos: Vector3

@export_category("Movement")
@export var move_speed: float = 7.0
@export var air_speed: float = 3.0
@export var sprint_speed: float = 10.0
@export var crouch_speed: float = 4.0
@export var gravity: float = -20.0
@export var jump_impulse: float = 7.0
@export var auto_bhop: bool = true
@export var toggle_sprint: bool

@export_category("Climb Movement")
@export var wall_player_offset: float = 1.0
@export var climb_speed: float = 10.0

@export_category("Air Movement")
@export var air_cap: float = 0.85
@export var air_accel: float = 800.0
@export var air_move_speed: float = 500.0

@export_category("Ground Movement")
@export var ground_accel: float = 14.0
@export var ground_decel: float = 10.0
@export var ground_friction: float = 6.0
@export var slide_accel: float = 1.0
@export var slide_decel: float = 10.0
@export var slide_friction: float = 1.0
@export var slide_threshold: float = 20.0

@export_category("Mouse")
@export var mouse_sens: float = 0.001

@export_category("PlayerAbilities")
@export var climb_abilitity: bool
