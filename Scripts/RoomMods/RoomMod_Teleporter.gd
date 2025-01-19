class_name RoomMod_Teleporter extends RoomMod

var cooldown : float = 2.5
const multiple : float = 1.25

func mod_name() -> String:
	return "Teleporter"
	
func can_advance() -> bool:
	return cooldown > 1.75

func advance() -> void:
	var new_value : float = min(1.75, cooldown / multiple)
	cooldown = new_value

func apply_to_room(_room : Room) -> void:
	pass

func apply_to_enemy(enemy : Enemy) -> void:
	enemy.teleport_cooldown = cooldown
	enemy.time_to_next_teleport = 0
