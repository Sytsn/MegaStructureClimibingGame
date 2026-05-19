extends Node

@onready var player_settings_res: PlayerSettingsRes = preload("res://Resources/Scenes/Player/player_settings.tres")

var doors: Array[Door] = []


func add_door(door: Door):
	doors.append(door)


func get_door(door_id: int):
	for door in doors:
		if door.door_id == door_id:
			return door
