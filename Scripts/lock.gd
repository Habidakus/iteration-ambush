extends StaticBody2D

class_name Lock
var room : Room = null

func init(_room : Room) -> void:
	room = _room

func remove_from_room() -> void:
	room.LockRemoved()
	queue_free()
