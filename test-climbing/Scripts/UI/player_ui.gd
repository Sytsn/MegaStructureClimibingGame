extends Control

@export var player: Player
var speed_label: RichTextLabel
var health_label: RichTextLabel
var secondary_cam: Camera3D

func _ready() -> void:
	speed_label = %Speed
	health_label = %Health
	if get_tree().current_scene:
		secondary_cam = get_tree().current_scene.get_node("Second Camera") as Camera3D
	print(secondary_cam)


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
