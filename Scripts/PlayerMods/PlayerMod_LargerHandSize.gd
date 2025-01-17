class_name PlayerMod_LargerModSelection extends PlayerMod

func get_title() -> String:
	return "Larger Mod Selection"

func get_description() -> String:
	return "You will be offered " + str(player.hand_size + 1) + " mods instead of the current " + str(player.hand_size) + " mods."
	
func is_available() -> bool:
	return player.hand_size < 4

func get_weight() -> float:
	return 1

func selected() -> void:
	player.hand_size += 1
