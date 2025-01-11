extends StateMachineState

var rooms : Array[Room]
var can_expand : float = -1
var go_active : bool = false

func _process(delta : float) -> void:
	if can_expand > 0:
		can_expand -= delta
		if can_expand <= 0:
			%PlayStateMachine.switch_state("PlayState_LevelAdvance")
		return
	if go_active:
		go_active = false
		can_expand = 5
		%PlayStateMachine.switch_state("PlayState_Active")

func enter_state() -> void:
	super.enter_state()
	%PlayStateMachine.switch_state("PlayState_LevelSetup")

func init_map() -> void:
	var r1 = Room.new()
	r1.x = 0
	r1.y = 0
	var r2 = Room.new()
	r2.x = 0
	r2.y = -1
	var r3 = Room.new()
	r3.x = -1
	r3.y = -1
	var r4 = Room.new()
	r4.x = -1
	r4.y = 0

	r1.north = r2
	r2.south = r1
	
	r2.west = r3
	r3.east = r2
	
	r3.south = r4
	r4.north = r3

	rooms.append(r1)
	rooms.append(r2)
	rooms.append(r3)
	rooms.append(r4)
	
	r1.ApplyToMaps(%TerrainMap, %ObjectMap)
	r2.ApplyToMaps(%TerrainMap, %ObjectMap)
	r3.ApplyToMaps(%TerrainMap, %ObjectMap)
	r4.ApplyToMaps(%TerrainMap, %ObjectMap)

func clean_map() -> void:
	print("TODO: CLEAN MAP")

func count_east(minX : int) -> int:
	var ret_val : int = 0
	for room : Room in rooms:
		if room.x >= minX:
			ret_val += 1
	return ret_val

func count_north(maxY : int) -> int:
	var ret_val : int = 0
	for room : Room in rooms:
		if room.y < maxY:
			ret_val += 1
	return ret_val

func move_east(minX : int) -> void:
	for room : Room in rooms:
		if room.x >= minX:
			room.ClearFromMaps(%TerrainMap, %ObjectMap)
			room.x += 1
	for room : Room in rooms:
		if room.x >= minX:
			room.ApplyToMaps(%TerrainMap, %ObjectMap)

func move_north(maxY : int) -> void:
	for room : Room in rooms:
		if room.y < maxY:
			room.ClearFromMaps(%TerrainMap, %ObjectMap)
			room.y -= 1
	for room : Room in rooms:
		if room.y < maxY:
			room.ApplyToMaps(%TerrainMap, %ObjectMap)

func get_pre_empty_rooms() -> Array[Room]:
	var ret_north : Array[Room]
	var ret_south : Array[Room]
	var ret_east : Array[Room]
	var ret_west : Array[Room]
	for room : Room in rooms:
		if room.north != null:
			if room.north.y != room.y - 1:
				ret_north.append(room)
		if room.east != null:
			if room.east.x != room.x + 1:
				ret_east.append(room)
		if room.south != null:
			if room.south.y != room.y + 1:
				ret_south.append(room)
		if room.west != null:
			if room.west.x != room.x - 1:
				ret_west.append(room)
	assert(ret_north.size() == ret_south.size())
	assert(ret_west.size() == ret_east.size())
	if ret_north.size() > ret_east.size():
		return ret_north
	else:
		return ret_east

func mutate_map() -> void:
	print("MUTATING MAP")
	if count_north(0) > count_east(0):
		move_east(0)
		var pre_empty_rooms = get_pre_empty_rooms()
		for room : Room in pre_empty_rooms:
			var old_dest = room.east
			var new_room = Room.new()
			new_room.x = room.x + 1
			new_room.y = room.y
			new_room.west = room
			new_room.east = old_dest
			room.east = new_room
			old_dest.west = new_room
			new_room.ApplyToMaps(%TerrainMap, %ObjectMap)
			rooms.append(new_room)
	else:
		move_north(0)
		var pre_empty_rooms = get_pre_empty_rooms()
		for room : Room in pre_empty_rooms:
			var old_dest = room.north
			var new_room = Room.new()
			new_room.x = room.x
			new_room.y = room.y - 1
			new_room.south = room
			new_room.north = old_dest
			room.north = new_room
			old_dest.south = new_room
			new_room.ApplyToMaps(%TerrainMap, %ObjectMap)
			rooms.append(new_room)

func spawn_map() -> void:
	print("TODO: SPAWN ENEMIES")
	go_active = true
