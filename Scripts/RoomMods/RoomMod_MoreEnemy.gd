class_name RoomMod_MoreEnemy extends RoomMod

var multiple : float = 1.0

func mod_name() -> String:
	return "More Enemy"

func can_advance() -> bool:
	return round(multiple * 1.25) < 10

func advance() -> void:
	multiple *= 1.25

func apply_to_room(room : Room) -> void:
	room.enemy_count = multiple

func apply_to_enemy(_enemy : Enemy) -> void:
	pass
