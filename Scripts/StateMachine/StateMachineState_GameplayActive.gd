extends StateMachineState

func enter_state() -> void:
	super.enter_state()
	our_state_machine.get_play_state().set_gameplay_active(true)

func exit_state(next_state: StateMachineState) -> void:
	our_state_machine.get_play_state().set_gameplay_active(false)
	super.exit_state(next_state)
