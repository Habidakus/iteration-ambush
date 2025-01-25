class_name RoomMod_DaggerThrower extends RoomMod

var multiple : float = 1.25
var reload_speed : float = 3.0 * multiple

func mod_name() -> String:
	return "Dagger Thrower"
	
func can_advance() -> bool:
	return reload_speed > 1.0

func advance() -> void:
	reload_speed /= multiple

func is_viable(room : Room) -> bool:
	return room.CanHaveDaggerThrower()

func apply_to_room(room : Room) -> void:
	room.dagger_thrower_reload = reload_speed

func apply_to_enemy(_enemy : Enemy) -> void:
	pass
