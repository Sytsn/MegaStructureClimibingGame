class_name FPSArms extends Node3D

@onready var ik: TwoBoneIK3D = $Rig/Skeleton3D/TwoBoneIK3D
@onready var hand_target: Node3D = $LHandTaget

var ik_active = false

func _ready() -> void:
	disable_ik()


func enable_ik():
	ik_active = true

func disable_ik():
	ik_active = false
	ik.enabled = false

#func _process(_delta):
	#if should_ik_wall_grab():
		#ik_active = true
		#hand_target.global_position = calculate_wall_grab_position()
	#else:
		#ik_active = false
		#ik.stop()
