extends StateMachineState

var state_play : PlayState = null

func enter_state() -> void:
	super.enter_state()
	var cs = get_tree().current_scene
	assert(cs)
	state_play = cs.find_child("State_Play") as PlayState
	assert(state_play)
	state_play.set_gameplay_active(true)

func exit_state(next_state: StateMachineState) -> void:
	state_play.set_gameplay_active(false)
	super.exit_state(next_state)
