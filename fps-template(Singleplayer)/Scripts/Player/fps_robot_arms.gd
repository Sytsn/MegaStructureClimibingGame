class_name FPSArms extends Node3D

@onready var ik: TwoBoneIK3D = %TwoBoneIK3D
@onready var l_hand_target: Node3D = %LHandTaget
@onready var r_hand_target: Node3D = %RHandTaget


var ik_active = false

func _ready() -> void:
	#disable_ik()
	pass


func enable_ik():
	ik_active = true
	ik.active = true


func disable_ik():
	ik_active = false
	ik.active = false

#func _process(_delta):
	#if should_ik_wall_grab():
		#ik_active = true
		#hand_target.global_position = calculate_wall_grab_position()
	#else:
		#ik_active = false
		#ik.stop()
