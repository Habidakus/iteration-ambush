extends Object

class_name DirectionRoomCollection

var from : Vector2i

var norths : Array[Room]
var souths : Array[Room]
var easts : Array[Room]
var wests : Array[Room]

func is_better(left : Array[Room], right : Array[Room]) -> bool:
	var left_empty : bool = left.is_empty()
	var right_empty : bool = right.is_empty()
	if left_empty != right_empty:
		return right_empty
	return left.size() <= right.size()

func is_north_least() -> bool:
	return is_better(norths, souths) and is_better(norths, easts) and is_better(norths, wests)
func is_south_least() -> bool:
	return is_better(souths, norths) and is_better(souths, easts) and is_better(souths, wests)
func is_east_least() -> bool:
	return is_better(easts, souths) and is_better(easts, norths) and is_better(easts, wests)
func is_west_least() -> bool:
	return is_better(wests, souths) and is_better(wests, norths) and is_better(wests, easts)
