extends StateMachineState

func _on_button_button_up() -> void:
	%State_Play.build_seed = 1
	our_state_machine.switch_state("State_Play")
