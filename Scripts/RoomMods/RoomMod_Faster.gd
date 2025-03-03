class_name RoomMod_Faster extends RoomMod

var multiple : float = 1.0

func mod_name() -> String:
	return "Faster"
	
func can_advance() -> bool:
	return multiple * 1.15 < 3.0

func advance() -> void:
	multiple *= 1.15

func is_viable(_room : Room) -> bool:
	return true

func apply_to_room(_room : Room) -> void:
	pass

func apply_to_enemy(enemy : Enemy) -> void:
	enemy.speed_multiple = multiple
