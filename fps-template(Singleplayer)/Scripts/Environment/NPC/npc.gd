class_name NPC extends Node


@export var npc_script_path: String
@export var interact_script: Node3D
@export var dialog_res: DialogRes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_script.set_script(load(npc_script_path)) 

func interact():
	interact_script.interact(dialog_res)
