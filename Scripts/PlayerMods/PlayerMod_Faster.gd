class_name PlayerMod_MoveFaster extends PlayerMod

const multiple = 1.2
func get_title() -> String:
	return "Move Faster"

func calculate_improved_speed() -> float:
	var potential_upgrade : float = min(player.MAX_SPEED, player.current_speed * multiple)
	potential_upgrade = min(player.current_bullet_speed(), potential_upgrade)
	return potential_upgrade

func get_description() -> String:
	var fraction : float = calculate_improved_speed() / player.current_speed
	return "Move " + str(round(100.0 * (fraction - 1.0))) + "% faster."

func is_available() -> bool:
	return player.current_speed < player.MAX_SPEED && player.current_speed < player.current_bullet_speed()

func get_weight() -> float:
	return 1

func selected() -> void:
	player.current_speed = calculate_improved_speed()
