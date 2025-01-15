extends StaticBody2D

class_name Key
var lock_id : int = -1
var room : Room = null

func init(id : int, containing_room : Room) -> void:
	lock_id = id
	room = containing_room

func remove_from_room() -> void:
	room.KeyGrabbed()
	queue_free()
