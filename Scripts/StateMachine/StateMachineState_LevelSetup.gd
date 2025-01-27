extends StateMachineState

var seed_value : int = 1

func enter_state() -> void:
	super.enter_state()
	var text_edit : TextEdit = find_child("TextEdit") as TextEdit
	seed_value = int(Time.get_unix_time_from_system()) % 1000
	text_edit.text = str(seed_value)
	%Player.visible = false

func exit_state(next_state: StateMachineState) -> void:
	%Player.visible = true
	var state_play : PlayState = our_state_machine.get_play_state()
	state_play.build_seed = seed_value
	state_play.init_player()
	state_play.init_map()
	state_play.spawn_map()
	super.exit_state(next_state)

func _on_text_edit_text_changed() -> void:
	var text_edit : TextEdit = find_child("TextEdit") as TextEdit
	if text_edit.text.is_valid_int():
		seed_value = text_edit.text.to_int()
	else:
		text_edit.text = str(seed_value)

func _on_easy_button_up() -> void:
	our_state_machine.get_play_state().difficulty = PlayState.Difficulty.Easy
	our_state_machine.switch_state("PlayState_Active")

func _on_medium_button_up() -> void:
	our_state_machine.get_play_state().difficulty = PlayState.Difficulty.Medium
	our_state_machine.switch_state("PlayState_Active")

func _on_hard_button_up() -> void:
	our_state_machine.get_play_state().difficulty = PlayState.Difficulty.Hard
	our_state_machine.switch_state("PlayState_Active")
