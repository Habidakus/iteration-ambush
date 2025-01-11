extends StateMachineState

func _on_button_button_up() -> void:
	our_state_machine.switch_state("State_Play")
