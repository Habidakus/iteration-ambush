class_name PlayerMod_Regeneration extends PlayerMod

func get_title() -> String:
	return "Regenerate"

func get_description() -> String:
	return "Heal 5 points every time you complete a circuit of the castle."

func is_available() -> bool:
	return player.has_regeneration == false

func get_weight() -> float:
	return 1

func selected() -> void:
	player.has_regeneration = true
