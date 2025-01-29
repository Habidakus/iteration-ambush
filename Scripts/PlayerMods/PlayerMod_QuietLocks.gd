class_name PlayerMod_QuietLocks extends PlayerMod

func get_title() -> String:
	return "Quiet Keys"

func get_description() -> String:
	return "You are quiet when you pick up keys, not waking monsters behind locks."

func is_available() -> bool:
	return player.quiet_locks == false && play_state.is_there_locked_room()

func get_weight() -> float:
	return 1

func selected() -> void:
	player.quiet_locks = true
