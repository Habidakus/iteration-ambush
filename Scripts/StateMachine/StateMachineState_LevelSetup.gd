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
	%State_Play.build_seed = seed_value
	%State_Play.init_player()
	%State_Play.init_map()
	%State_Play.spawn_map()
	super.exit_state(next_state)

func _on_text_edit_text_changed() -> void:
	var text_edit : TextEdit = find_child("TextEdit") as TextEdit
	if text_edit.text.is_valid_int():
		seed_value = text_edit.text.to_int()
	else:
		text_edit.text = str(seed_value)

func _on_easy_button_up() -> void:
	%State_Play.difficulty = %State_Play.Difficulty.Easy
	our_state_machine.switch_state("PlayState_Active")

func _on_medium_button_up() -> void:
	%State_Play.difficulty = %State_Play.Difficulty.Medium
	our_state_machine.switch_state("PlayState_Active")

func _on_hard_button_up() -> void:
	%State_Play.difficulty = %State_Play.Difficulty.Hard
	our_state_machine.switch_state("PlayState_Active")
