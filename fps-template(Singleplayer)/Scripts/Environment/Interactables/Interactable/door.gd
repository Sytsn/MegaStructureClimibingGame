@tool
class_name Door extends AnimatableBody3D


var starting_pos: Vector3
var ending_pos: Vector3
var door_tween: Tween


@export var open_dir: Vector3
@export var open_dist: float
@export var is_locked: bool
@export var opening_time: float
@export var door_id: int


func _func_godot_apply_properties(entity_properties: Dictionary) -> void:
	if "open_dir" in entity_properties:
		open_dir = entity_properties["open_dir"] as Vector3
	if "open_dist" in entity_properties:
		open_dist = entity_properties["open_dist"] as float
	if "opening_time" in entity_properties:
		opening_time = entity_properties["opening_time"] as float
	if "is_locked" in entity_properties:
		is_locked = entity_properties["is_locked"] as bool
	if "door_id" in entity_properties:
		door_id = entity_properties["door_id"] as int


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	print("door_id", door_id)
	print("open_dist", open_dist)
	print("is_locked", is_locked)
	print("opening_time", opening_time)
	
	starting_pos = position
	ending_pos = starting_pos + (open_dir * open_dist)
	Global.add_door(self)


func interact():
	print("interact")
	if !is_locked:
		print("open Door")
		open_door()


func unlock():
	is_locked = false


func open_door() -> void:
	if door_tween and door_tween.is_running():
		door_tween.kill()
	
	door_tween = create_tween()
	door_tween.tween_property(self, "position", ending_pos, opening_time)
	print(position)
