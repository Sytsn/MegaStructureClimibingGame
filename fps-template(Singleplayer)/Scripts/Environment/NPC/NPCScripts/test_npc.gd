extends Node3D


func interact(dialog: DialogRes):
	var root = get_tree().root
	var player = root.find_child("Player", true, false)
	player.enter_dialog(dialog)
