class_name PlayerMod_FireResistance extends PlayerMod

const multiple = 1.5
func get_title() -> String:
	return "Fire Resistance"

func get_description() -> String:
	return "Take " + str(round(100.0 * (multiple - 1.0))) + "% less damage when in the fire pits."

func is_available() -> bool:
	return true

func get_weight() -> float:
	return 1

func selected() -> void:
	player.fire_resistance *= multiple
