extends StateMachine

var play_state : PlayState = null

func get_play_state() -> PlayState:
	if play_state == null:
		var cs = get_tree().current_scene
		assert(cs)
		play_state = cs.find_child("State_Play") as PlayState
		assert(play_state)
	
	return play_state
