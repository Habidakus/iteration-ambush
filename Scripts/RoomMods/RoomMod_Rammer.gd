class_name RoomMod_Rammer extends RoomMod

var multiple : float = 1.0

func mod_name() -> String:
	return "Rammer"
	
func can_advance() -> bool:
	return true

func advance() -> void:
	multiple *= 1.25

func is_viable(_room : Room) -> bool:
	return true

func apply_to_room(_room : Room) -> void:
	pass

func apply_to_enemy(enemy : Enemy) -> void:
	enemy.ram_damage *= multiple
