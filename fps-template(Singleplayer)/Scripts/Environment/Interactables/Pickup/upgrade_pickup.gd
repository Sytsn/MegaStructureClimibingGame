class_name UpgradAbility extends Node3D

@export var upgrade_path: String
@export var door_id: int


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		var upgrade = load(upgrade_path)
		var scripts_node = body.find_child("Scripts")
		var instance = upgrade.instantiate()
		scripts_node.add_child(instance)
		body.climbing_movement_setup(instance)
		self.queue_free()
		
		if door_id:
			var door = Global.get_door(door_id)
			door.unlock()
			door.open_door()
