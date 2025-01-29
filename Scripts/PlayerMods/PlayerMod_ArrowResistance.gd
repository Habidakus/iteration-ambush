class_name PlayerMod_ArrowResistance extends PlayerMod

const multiple = 2
func get_title() -> String:
	return "Arrow Resistance"

func get_description() -> String:
	return "Take " + str(round(100.0 * (1.0 - (1.0 / multiple)))) + "% less damage when struck with an arrow."

func is_available() -> bool:
	return play_state.is_there_a_dagger_thrower()

func get_weight() -> float:
	return 1

func selected() -> void:
	player.arrow_resistance *= multiple
