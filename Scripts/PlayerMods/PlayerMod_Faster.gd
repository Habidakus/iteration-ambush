class_name PlayerMod_MoveFaster extends PlayerMod

const multiple = 1.2
func get_title() -> String:
	return "Move Faster"

func get_description() -> String:
	return "Move " + str(round(100.0 * (multiple - 1.0))) + "% faster."

func is_available() -> bool:
	return player.current_speed < player.MAX_SPEED

func get_weight() -> float:
	return 1

func selected() -> void:
	player.current_speed = min(player.MAX_SPEED, player.current_speed * multiple)
