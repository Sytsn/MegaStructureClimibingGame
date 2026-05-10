class_name Door extends Node3D


var is_locked: bool


func interact():
	if !is_locked:
		queue_free()


func unlock():
	is_locked = false
