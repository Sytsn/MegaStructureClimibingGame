extends Control

@export var player: Player
var speed_label: RichTextLabel
var health_label: RichTextLabel


func _ready() -> void:
	speed_label = %Speed
	health_label = %Health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed_label.text = "Speed: " + str(player.velocity.length())
	health_label.text = str(player.health.curr_health)


func _on_damage_pressed() -> void:
	player.health._take_damage(25)
