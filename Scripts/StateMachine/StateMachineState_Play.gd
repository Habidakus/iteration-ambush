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

#func count_east(minX : int) -> int:
	#var ret_val : int = 0
	#for room : Room in rooms:
		#if room.x >= minX:
			#ret_val += 1
	#return ret_val
#
#func count_north(maxY : int) -> int:
	#var ret_val : int = 0
	#for room : Room in rooms:
		#if room.y < maxY:
			#ret_val += 1
	#return ret_val

func move(rooms_to_move : Array[Room], dir : Vector2i) -> DirectionRoomCollection:
	for room : Room in rooms_to_move:
		room.ClearFromMaps(%TerrainMap, %ObjectMap)
		print("Moving " + str(room.x) + "," + str(room.y) + " by " + str(dir))
		room.x += dir.x
		room.y += dir.y
	var ret_val : DirectionRoomCollection = DirectionRoomCollection.new()
	for room : Room in rooms_to_move:
		room.ApplyToMaps(%TerrainMap, %ObjectMap)
		if room.north != null && room.north.y != room.y - 1:
			ret_val.norths.append(room)
			ret_val.souths.append(room.north)
		if room.south != null && room.south.y != room.y + 1:
			ret_val.souths.append(room)
			ret_val.norths.append(room.south)
		if room.east != null && room.east.x != room.x + 1:
			ret_val.easts.append(room)
			ret_val.wests.append(room.east)
		if room.west != null && room.west.x != room.x - 1:
			ret_val.wests.append(room)
			ret_val.easts.append(room.west)
	return ret_val

#func get_pre_empty_rooms() -> Array[Room]:
	#var ret_north : Array[Room]
	#var ret_south : Array[Room]
	#var ret_east : Array[Room]
	#var ret_west : Array[Room]
	#for room : Room in rooms:
		#if room.north != null:
			#if room.north.y != room.y - 1:
				#ret_north.append(room)
		#if room.east != null:
			#if room.east.x != room.x + 1:
				#ret_east.append(room)
		#if room.south != null:
			#if room.south.y != room.y + 1:
				#ret_south.append(room)
		#if room.west != null:
			#if room.west.x != room.x - 1:
				#ret_west.append(room)
	#assert(ret_north.size() == ret_south.size())
	#assert(ret_west.size() == ret_east.size())
	#if ret_north.size() > ret_east.size():
		#return ret_north
	#else:
		#return ret_east

func generate_direction_room_collection(loc : Vector2i) -> DirectionRoomCollection:
	var ret_val : DirectionRoomCollection = DirectionRoomCollection.new()
	for room : Room in rooms:
		if room.x >= loc.x:
			ret_val.easts.append(room)
		else:
			ret_val.wests.append(room)
		if room.y >= loc.y:
			ret_val.souths.append(room)
		else:
			ret_val.norths.append(room)
	return ret_val
		
func mutate_map() -> void:
	var drc : DirectionRoomCollection = generate_direction_room_collection(Vector2i.ZERO)
	var pre_empty_rooms : Array[Room]
	var result : DirectionRoomCollection
	var move_direction : Vector2i
	if drc.is_east_least():
		move_direction = Vector2i(1, 0)
		result = move(drc.easts, move_direction)
		pre_empty_rooms = result.easts
		print("MUTATING MAP: East " + str(pre_empty_rooms.size()))
	elif drc.is_north_least():
		move_direction = Vector2i(0, -1)
		result = move(drc.norths, move_direction)
		pre_empty_rooms = result.norths
		print("MUTATING MAP: North " + str(pre_empty_rooms.size()))
	elif drc.is_west_least():
		move_direction = Vector2i(-1, 0)
		result = move(drc.wests, move_direction)
		pre_empty_rooms = result.wests
		print("MUTATING MAP: West " + str(pre_empty_rooms.size()))
	else: # south
		move_direction = Vector2i(0, 1)
		result = move(drc.souths, move_direction)
		pre_empty_rooms = result.souths
		print("MUTATING MAP: South " + str(pre_empty_rooms.size()))

	for room : Room in pre_empty_rooms:
		#var old_dest : Room = room.east
		var new_room : Room = Room.new()
		new_room.x = room.x + move_direction.x
		new_room.y = room.y + move_direction.y
		print("Adding at " + str(new_room.x) + "," + str(new_room.y))
		if move_direction.x > 0:
			var old_dest : Room = room.east
			new_room.west = room
			new_room.east = old_dest
			room.east = new_room
			old_dest.west = new_room
		elif move_direction.x < 0:
			var old_dest : Room = room.west
			new_room.east = room
			new_room.west = old_dest
			room.west = new_room
			old_dest.east = new_room

		elif move_direction.y > 0:
			var old_dest : Room = room.south
			new_room.north = room
			new_room.south = old_dest
			room.south = new_room
			old_dest.north = new_room
		elif move_direction.y < 0:
			var old_dest : Room = room.north
			new_room.south = room
			new_room.north = old_dest
			room.north = new_room
			old_dest.south = new_room

		new_room.ApplyToMaps(%TerrainMap, %ObjectMap)
		rooms.append(new_room)

func spawn_map() -> void:
	print("TODO: SPAWN ENEMIES")
	go_active = true
