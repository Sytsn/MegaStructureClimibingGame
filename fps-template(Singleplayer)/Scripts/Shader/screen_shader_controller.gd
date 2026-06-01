class_name ScreenShaderController extends Node

@export var mesh: MeshInstance3D
@export_category("Parameters")
@export_range(0.0, 20.0, 1.0) var pixel_size: float = 1.0
@export_range(0.0, 100.0, 1.0) var levels: float = 95.0
@export_range(0.0, 1.0, 0.01) var gamma_x: float = 0.1
@export_range(0.0, 20.0, 0.01) var gamma_y: float = 11.25
var mat: ShaderMaterial

func _ready():
	mat = mesh.get_active_material(0) as ShaderMaterial
	if mat:
		mat.set_shader_parameter("pixel_size", pixel_size)
		mat.set_shader_parameter("levels", levels)
		mat.set_shader_parameter("gamma", Vector2(gamma_x, gamma_y))


func set_pixel_size(size: float):
	mat.set_shader_parameter("pixel_size", size)


func set_levels(levels: float):
	mat.set_shader_parameter("levels", levels)


func set_gamma(gamma: Vector2):
	mat.set_shader_parameter("gamma", gamma)
