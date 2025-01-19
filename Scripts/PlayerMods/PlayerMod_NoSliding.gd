class_name PlayerMod_NoSliding extends PlayerMod

func get_title() -> String:
	return "Hobnail Boots"

func get_description() -> String:
	return "No more sliding around on the floor. Equip your old hob-nail boots for firm traction."

func is_available() -> bool:
	return player.has_cleats == false

func get_weight() -> float:
	return 1

func selected() -> void:
	player.has_cleats = true
