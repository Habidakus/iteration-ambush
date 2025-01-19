class_name PlayerMod_FurtherBullets extends PlayerMod

const multiple = 1.25
func get_title() -> String:
	return "Throw Farther"

func get_description() -> String:
	return "Throw the scythe " + str(round(100.0 * (multiple - 1.0))) + "% further."

func is_available() -> bool:
	return player.get_total_bullet_distance() < 64 * 15 * 1.5

func get_weight() -> float:
	return 1

func selected() -> void:
	player.bullet_lifetime = player.bullet_lifetime * sqrt(multiple)
	player.bullet_speed = player.bullet_speed * sqrt(multiple)
