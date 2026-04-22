class_name Health extends Object


var max_health: float
var min_health: float
var curr_health: float
var heal_rate: float
var full_heal_time: float


var owner_node: Node3D = null
var is_healing: bool = false
var heal_speed: float = 0.0

signal damage_taken
signal dead

func _init(max_hp: float = 100.0
	, min_hp: float = 0.0
	, h_rate: float = 1.0
	, full_h_time: float = 2.0) -> void:
	max_health = max_hp
	min_health = min_hp
	heal_rate = h_rate
	full_heal_time = full_h_time
	curr_health = max_health


func _start_healing():
	var missing_health = max_health - curr_health
	var heal_time = (missing_health / max_health) * full_heal_time
	heal_speed = missing_health / heal_time
	is_healing = true


func _take_damage(damage: float):
	if (curr_health - damage) <= min_health:
		_die()
	if (curr_health - damage) > min_health:
		curr_health -= damage
		emit_signal("damage_taken")


func _die():
	curr_health = min_health
	emit_signal("dead")


func _heal(heal: float):
	if (curr_health + heal) <= max_health:
		curr_health += heal
	if (curr_health + heal) > max_health:
		curr_health = max_health


func _heal_over_time(delta: float):
	curr_health = min(curr_health + heal_speed * delta, max_health)
	if curr_health >= max_health:
		is_healing = false


func _set_max_health(health: float):
	max_health = health
	
	
func _set_min_health(health: float):
	min_health = health
