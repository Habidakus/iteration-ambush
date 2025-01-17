class_name PlayerMod_MoreDamage extends PlayerMod

const multiple = 1.2
func get_title() -> String:
	return "More Damage"

func get_description() -> String:
	return "Scythe does " + str(round(100.0 * (multiple - 1.0))) + "% more damage\n(from " + str(round(player.shot_damage)) + " to " + str(round(player.shot_damage * multiple)) + ")"

func is_available() -> bool:
	return true

func get_weight() -> float:
	return 1

func selected() -> void:
	player.shot_damage *= multiple
