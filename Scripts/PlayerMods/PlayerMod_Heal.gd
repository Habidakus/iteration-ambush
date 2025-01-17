class_name PlayerMod_Heal extends PlayerMod

func get_title() -> String:
	match play_state.difficulty:
		PlayState.Difficulty.Easy: return "Big Heal"
		PlayState.Difficulty.Medium: return "Heal"
		PlayState.Difficulty.Hard: return "Small Heal"
	return "???"

func amount() -> int:
	var m : int = 0
	match play_state.difficulty:
		PlayState.Difficulty.Easy: m = 40
		PlayState.Difficulty.Medium: m = 20
		PlayState.Difficulty.Hard: m = 10
	return m

func get_description() -> String:
	return "Heal up to " + str(amount()) + " health."

func is_available() -> bool:
	return player.current_health < player.max_health

func get_weight() -> float:
	var down : float = player.max_health - player.current_health
	if amount() < down / 2.0:
		return 0.5
	if amount() <= down:
		return 1
	return 2

func selected() -> void:
	player.current_health = min(player.current_health + amount(), player.max_health)
	player.set_health_bar()
