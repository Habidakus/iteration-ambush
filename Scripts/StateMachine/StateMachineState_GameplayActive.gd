extends StateMachineState

func enter_state() -> void:
	super.enter_state()
	%State_Play.is_gameplay_active = true

func exit_state(next_state: StateMachineState) -> void:
	%State_Play.is_gameplay_active = false
	super.exit_state(next_state)
