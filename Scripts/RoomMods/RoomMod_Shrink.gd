class_name RoomMod_Shrink extends RoomMod

var multiple : float = 1.0

func mod_name() -> String:
	return "Shrink"
	
func can_advance() -> bool:
	return multiple * 1.15 < 3

func advance() -> void:
	multiple *= 1.15

func apply_to_room(_room : Room) -> void:
	pass

func apply_to_enemy(enemy : Enemy) -> void:
	enemy.scale /= multiple
