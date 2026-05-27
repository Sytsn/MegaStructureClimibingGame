class_name DialogOption extends CenterContainer


@export var button: Button
var dialog_manager: DialogManager
var dialog_continuation: DialogRes


func _ready():
	var root = get_tree().root
	dialog_manager = root.find_child("DialogManager", true, false)


func _on_button_pressed() -> void:
	if dialog_continuation != null:
		dialog_manager.enter_dialog(dialog_continuation)
	else:
		dialog_manager.exit_dialog()


func set_button(dialog_response: DialogResponseRes):
	button.text = dialog_response.dialog_response
	dialog_continuation = dialog_response.dialog_res
