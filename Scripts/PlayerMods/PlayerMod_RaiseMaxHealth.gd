class_name PlayerMod_RaiseMaxHealth extends PlayerMod

func get_title() -> String:
	return "Raise Max Health"

func amount() -> int:
	return 10

func get_description() -> String:
	return "Raise your maximum health by " + str(amount()) + ".\nWARNING: Does not heal current wounds."

func is_available() -> bool:
	return player.current_health * 2 > player.max_health

func get_weight() -> float:
	return 1

func selected() -> void:
	player.max_health += amount()
	player.set_health_bar()
