class_name PlayerMod_FurtherBullets extends PlayerMod

const multiple = 1.25
func get_title() -> String:
	return "Throw Farther"

func get_description() -> String:
	return "Throw the scythe " + str(round(100.0 * (multiple - 1.0))) + "% further."

func is_available() -> bool:
	return player.bullet_lifetime * multiple < 3

func get_weight() -> float:
	return 1

func selected() -> void:
	player.bullet_lifetime = min(3, player.bullet_lifetime * multiple)
