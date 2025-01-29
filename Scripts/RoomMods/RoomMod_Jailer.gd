class_name RoomMod_Jailer extends RoomMod

var has_advanced : bool = false
func mod_name() -> String:
	return "Jailer"
	
func can_advance() -> bool:
	return has_advanced

func advance() -> void:
	has_advanced = true

func is_viable(room : Room) -> bool:
	return room.has_jailer == false

func apply_to_room(room : Room) -> void:
	room.has_jailer = true

func apply_to_enemy(enemy : Enemy) -> void:
	enemy.jailer = true
