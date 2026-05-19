@tool
extends Node


@export var door_id: int
@export var unlock_door: bool
@export var auto_open: bool
@export var single_use: bool

var door: Door
var is_used: bool = false


func _func_godot_apply_properties(entity_properties: Dictionary) -> void:
	if "unlock_door" in entity_properties:
		unlock_door = entity_properties["unlock_door"] as bool
	if "auto_open" in entity_properties:
		auto_open = entity_properties["auto_open"] as bool
	if "single_use" in entity_properties:
		single_use = entity_properties["single_use"] as bool
	if "door_id" in entity_properties:
		door_id = entity_properties["door_id"] as int


func _ready() -> void:
	if door_id:
		door = Global.get_door(door_id)


func interact():
	if auto_open:
		door.is_locked = false
		door.open_door()
		if single_use:
			is_used = true
		return
	if unlock_door:
		print("unlock")
		door.is_locked = false
