class_name PlayerMod_FireFaster extends PlayerMod

const multiple = 1.2
func get_title() -> String:
	return "Faster Reload"

func get_description() -> String:
	return "Reload " + str(round(100.0 * (multiple - 1.0))) + "% faster.\n(from " + str(round(player.fire_cooldown_max * 100) / 100.0) + " sec to " + str(round(player.fire_cooldown_max / multiple * 100) / 100.0) + " sec)"

func is_available() -> bool:
	return player.fire_cooldown_max > 0.5

func get_weight() -> float:
	return 1

func selected() -> void:
	player.fire_cooldown_max /= multiple
