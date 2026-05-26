class_name DialogManager extends Node


@onready var dialog_text: RichTextLabel = %Dialog
var dialog_res: DialogRes
var dialog_keys := []
var dialog_index := 0


func enter_dialog(dialog: DialogRes):
	self.visible = true
	dialog_res = dialog
	get_dialog()


func get_dialog():
	dialog_keys = dialog_res.dialog_text.keys()
	dialog_index = 0
	show_current_line()


func show_current_line():
	if dialog_index >= dialog_keys.size():
		return
	var key = dialog_keys[dialog_index]
	dialog_text.text = dialog_res.dialog_text[key]


func advance_dialog():
	print("advance")
	dialog_index += 1
	print("index", dialog_index)
	print("size", dialog_keys.size())
	print(dialog_index > dialog_keys.size())
	if dialog_index > dialog_keys.size():
		return false
	show_current_line()
