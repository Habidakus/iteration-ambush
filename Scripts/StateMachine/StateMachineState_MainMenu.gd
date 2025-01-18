extends StateMachineState

func enter_state() -> void:
	super.enter_state()
	do_shader_preload()
	
func do_shader_preload():
	var shader : ShaderMaterial = load("res://Scene/fire_pit_material.tres")
	var ca : CanvasItem = ColorRect.new()
	ca.material = shader
	add_child(ca)
	ca.call_deferred("queue_free")
	
func _on_button_button_up() -> void:
	%State_Play.build_seed = 1
	our_state_machine.switch_state("State_Play")

func _on_button_tools_button_up() -> void:
	our_state_machine.switch_state("State_Tools")

func _on_button_credits_button_up() -> void:
	our_state_machine.switch_state("State_Credits")

func _on_button_story_button_up() -> void:
	our_state_machine.switch_state("State_Story")
