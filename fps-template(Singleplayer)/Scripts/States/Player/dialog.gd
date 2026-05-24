extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	#camera should lock onto npc
	pass


func physics_update(delta: float) -> void:
	pass


func handle_input(event: InputEvent) -> void:
	pass


func update(delta: float) -> void:
	ui_inputs()
	if Input.is_action_just_pressed("climb_action"):
		player.exit_dialog()
	if player.is_in_dialog == false:
		finished.emit(IDLE)
