extends StateMachineState

func enter_state() -> void:
	super.enter_state()
	%State_Play.init_map()
	%State_Play.spawn_map()
