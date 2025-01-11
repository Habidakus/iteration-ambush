extends StateMachineState

func enter_state() -> void:
	super.enter_state()
	%State_Play.clean_map()
	%State_Play.mutate_map()
	%State_Play.spawn_map()
