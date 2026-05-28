class_name PlayerUI extends Control

@export var player: Player
var speed_label: RichTextLabel
var health_label: RichTextLabel
var interact: RichTextLabel
var secondary_cam: Camera3D
var dialog_text: RichTextLabel
var dialog_container: ColorRect
@onready var dialog_manager: DialogManager = %DialogManager


func _ready() -> void:
	player.clamber_prompt.connect(clamber_prompt)
	player.toggle_interact_prompt.connect(toggle_interact_prompt)
	player.set_interact_prompt.connect(set_interact_prompt)
	dialog_manager.exit_dialog_signal.connect(exit_dialog_text)
	speed_label = %Speed
	health_label = %Health
	interact = %Interact
	dialog_text = %Dialog
	dialog_manager.visible = false
	interact.visible = false
	if get_tree().current_scene:
		secondary_cam = get_tree().current_scene.get_node("Second Camera") as Camera3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed_label.text = "Speed: " + str(player.velocity.length())
	health_label.text = str(player.health.curr_health)


func _on_damage_pressed() -> void:
	if !player.camera.current:
		player.camera.current = true
		secondary_cam.current = false
	else:
		secondary_cam.current = true
		player.camera.current = false


func set_dialog_text(dialog: DialogRes):
	player.is_in_dialog = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	dialog_manager.enter_dialog(dialog)


func advance_dialog():
	var res = dialog_manager.advance_dialog()
	if res == false:
		dialog_manager.exit_dialog()
		exit_dialog_text()


func exit_dialog_text():
	player.is_in_dialog = false
	dialog_manager.visible = false


func clamber_prompt(visiblity: bool):
	toggle_interact_prompt(visiblity)
	set_interact_prompt("Press Space to Clamber")
	player.can_clamber = visiblity


func toggle_interact_prompt(toggle: bool):
	interact.visible = toggle


func set_interact_prompt(prompt: String = "Press F to Interact"):
	interact.text = prompt
