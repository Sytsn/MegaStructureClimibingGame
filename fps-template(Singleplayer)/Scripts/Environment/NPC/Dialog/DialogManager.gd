class_name DialogManager extends Node


@onready var dialog_text: RichTextLabel = %Dialog
@onready var dialog_option_text: RichTextLabel = %DialogOptionText
@onready var dialog_option_container = %DialogOptionContainer
@onready var dialog_option_background = %DialogOptionBackground
@onready var dialog_option_scene: PackedScene = preload("res://Scenes/Environment/NPC/Dialog/ DialogOption.tscn")
var dialog_res: DialogRes
var dialog_keys := []
var dialog_index := 0
var dialog_options: Array[DialogOption]

var is_in_response: bool = false


func _ready() -> void:
	dialog_option_background.visible = false


func reset():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.visible = false
	dialog_res = DialogRes.new()
	var dialog_keys := []
	var dialog_index := 0
	dialog_option_background.visible = false
	is_in_response = false
	print(dialog_options)
	for dialog_option in dialog_options:
		if is_instance_valid(dialog_option):
			dialog_option.queue_free()


func enter_dialog(dialog: DialogRes):
	reset()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	self.visible = true
	dialog_res = dialog
	get_dialog()

func exit_dialog():
	reset()


func get_dialog():
	dialog_keys = dialog_res.dialog_text.keys()
	dialog_index = 0
	show_current_line()


func show_current_line():
	if dialog_index >= dialog_keys.size():
		return
	print("dialog_response_keys ", dialog_res.dialog_response.keys())
	print("curr_dialog_key ", dialog_keys[dialog_index])
	var key = dialog_keys[dialog_index]
	if dialog_res.dialog_response.has(dialog_keys[dialog_index]):
		dialog_option_text.text = dialog_res.dialog_text[key]
		show_dialog_response(dialog_res.dialog_response[dialog_keys[dialog_index]])
	else:
		dialog_text.text = dialog_res.dialog_text[key]


func advance_dialog():
	if is_in_response:
		return true
	dialog_index += 1
	if dialog_index >= dialog_keys.size():
		return false
	show_current_line()
	return true


func show_dialog_response(dialog_response):
	is_in_response = true
	self.visible = false
	dialog_option_background.visible = true
	for response in dialog_response.dialog_responses_res:
		var dialog_option: DialogOption = dialog_option_scene.instantiate()
		dialog_option.set_button(response)
		dialog_option_container.add_child(dialog_option)
		dialog_options.append(dialog_option)
			
