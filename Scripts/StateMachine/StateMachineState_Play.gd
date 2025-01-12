extends StateMachineState

class_name PlayState

var rooms : Array[Room]
var go_active : bool = false
var is_gameplay_active : bool = false

var first_room : Room
var last_room : Room

# TODO: Make global
var last_room_atlas : Vector2i = Vector2i(1, 0)

func _process(_delta : float) -> void:
	if go_active:
		go_active = false
		%PlayStateMachine.switch_state("PlayState_Active")
	#if is_gameplay_active:
		#queue_redraw()

#func _draw() -> void:
	#for room : Room in rooms:
		#room.DrawRoomNumber()

func apply_tile(terrain_atlas_pos : Vector2i) -> void:
	if terrain_atlas_pos == last_room_atlas:
		%PlayStateMachine.switch_state("PlayState_LevelAdvance")

func get_room_central_pos(grid_x : int, grid_y : int) -> Vector2:
	var local_pos = (%TerrainMap as TileMapLayer).map_to_local(Vector2i(grid_x * 15 + 7, grid_y * 15 + 7))
	return local_pos

func get_player() -> Player:
	return %Player

func trigger_player_location_events(player_loc : Vector2) -> void:
		
	var map_pos : Vector2i = (%TerrainMap as TileMapLayer).local_to_map(player_loc)
	var atlas = (%TerrainMap as TileMapLayer).get_cell_atlas_coords(map_pos)
	if atlas.x != -1:
		apply_tile(atlas)
		#var tile_data : TileData = (%TerrainMap as TileMapLayer).get_cell_tile_data(map_pos)
		#print(str(atlas) + " " + str(tile_data))
	
	if is_gameplay_active == false:
		return
	
	var grid_fx : float = (map_pos.x / 15.0)
	var grid_fy : float = (map_pos.y / 15.0)
	var grid_x : int = floor(grid_fx)
	var grid_y : int = floor(grid_fy)
	for room : Room in rooms:
		if room.x == grid_x && room.y == grid_y:
			room.UpdatePlayerInRoom()
			return

func player_entered_room_for_first_time(_room : Room) -> void:
	pass

func enter_state() -> void:
	super.enter_state()
	%PlayStateMachine.switch_state("PlayState_LevelSetup")

func init_map() -> void:
	var r1 = Room.CreateRoom(0, 0, self)
	var r2 = Room.CreateRoom(0, -1, self)
	var r3 = Room.CreateRoom(-1, -1, self)
	var r4 = Room.CreateRoom(-1, 0, self)
	r1.has_enemy = false
	r4.has_enemy = false
	r4.SetAsLastRoom()

	connect_rooms(r1, r2)
	connect_rooms(r2, r3)
	connect_rooms(r3, r4)

	rooms.append(r1)
	rooms.append(r2)
	rooms.append(r3)
	rooms.append(r4)
	
	r1.ApplyToMaps(%TerrainMap, %ObjectMap)
	r2.ApplyToMaps(%TerrainMap, %ObjectMap)
	r3.ApplyToMaps(%TerrainMap, %ObjectMap)
	r4.ApplyToMaps(%TerrainMap, %ObjectMap)
	
	first_room = r1
	last_room = r4

func connect_rooms(left : Room, right : Room) -> void:
	if left.x + 1 == right.x:
		left.east = right
		right.west = left
	elif left.x - 1 == right.x:
		left.west = right
		right.east = left
	elif left.y - 1 == right.y:
		left.north = right
		right.south = left
	elif left.y + 1 == right.y:
		left.south = right
		right.north = left
	else:
		assert(false)

func clean_map() -> void:
	for room : Room in rooms:
		room.ResetRoom()

func move(rooms_to_move : Array[Room], dir : Vector2i) -> DirectionRoomCollection:
	for room : Room in rooms_to_move:
		room.ClearFromMaps(%TerrainMap, %ObjectMap)
		#print("Moving " + str(room.x) + "," + str(room.y) + " by " + str(dir))
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

var mutate_count : int = 0
func mutate_map() -> void:
	mutate_count += 1
	if mutate_count % 2 == 0:
		if mutate_map_extrude():
			return
	mutate_map_extend()

func is_empty_room(x : int, y : int) -> bool:
	for room : Room in rooms:
		if room.x == x and room.y == y:
			return false
	return true

func mutate_map_extrude() -> bool:
	var potential_east : Array[Room]
	var potential_west : Array[Room]
	var potential_north : Array[Room]
	var potential_south : Array[Room]
	for room : Room in rooms:
		if room.north != null:
			if is_empty_room(room.x + 1, room.y) && is_empty_room(room.north.x + 1, room.north.y):
				potential_east.append(room)
			if is_empty_room(room.x - 1, room.y) && is_empty_room(room.north.x - 1, room.north.y):
				potential_west.append(room)
		if room.east != null:
			if is_empty_room(room.x, room.y - 1) && is_empty_room(room.east.x, room.east.y - 1):
				potential_north.append(room)
			if is_empty_room(room.x, room.y + 1) && is_empty_room(room.east.x, room.east.y + 1):
				potential_south.append(room)
	var count : int = potential_east.size() + potential_west.size() + potential_north.size() + potential_south.size()
	if count == 0:
		print("Failed to extrude")
		return false
	print("TODO: mutate_map_extrude() should be random")
	var index : int = mutate_count % count
	if index < potential_east.size():
		extrude_map(potential_east[index], potential_east[index].north, Vector2i(1, 0))
		return true
	index -= potential_east.size()
	
	if index < potential_west.size():
		extrude_map(potential_west[index], potential_west[index].north, Vector2i(-1, 0))
		return true
	index -= potential_west.size()
	
	if index < potential_north.size():
		extrude_map(potential_north[index], potential_north[index].east, Vector2i(0, -1))
		return true
	index -= potential_north.size()
		
	if index < potential_south.size():
		extrude_map(potential_south[index], potential_south[index].east, Vector2i(0, 1))
		return true
		
	assert(false)
	return false
	
func extrude_map(room_a : Room, room_b : Room, dir : Vector2i) -> void:
	#print("Extruding " + str(room_a.x) + "," + str(room_a.y) + " towards " + str(dir))
	var new_room_a : Room = Room.CreateRoom(room_a.x + dir.x, room_a.y + dir.y, self)
	#print("Extruding " + str(room_b.x) + "," + str(room_b.y) + " towards " + str(dir))
	var new_room_b : Room = Room.CreateRoom(room_b.x + dir.x, room_b.y + dir.y, self)
	if room_a.north == room_b:
		new_room_a.north = new_room_b
		new_room_b.south = new_room_a
		room_a.north = null
		room_b.south = null
	elif room_a.south == room_b:
		new_room_a.south = new_room_b
		new_room_b.north = new_room_a
		room_a.south = null
		room_b.north = null
	elif room_a.east == room_b:
		new_room_a.east = new_room_b
		new_room_b.west = new_room_a
		room_a.east = null
		room_b.west = null
	elif room_a.west == room_b:
		new_room_a.west = new_room_b
		new_room_b.east = new_room_a
		room_a.west = null
		room_b.east = null
	else:
		assert(false)
	rooms.append(new_room_a)
	rooms.append(new_room_b)
	connect_rooms(room_a, new_room_a)
	connect_rooms(room_b, new_room_b)
	room_a.ClearFromMaps(%TerrainMap, %ObjectMap)
	room_b.ClearFromMaps(%TerrainMap, %ObjectMap)
	room_a.ApplyToMaps(%TerrainMap, %ObjectMap)
	room_b.ApplyToMaps(%TerrainMap, %ObjectMap)
	new_room_a.ApplyToMaps(%TerrainMap, %ObjectMap)
	new_room_b.ApplyToMaps(%TerrainMap, %ObjectMap)

func mutate_map_extend() -> void:
	var drc : DirectionRoomCollection = generate_direction_room_collection(Vector2i.ZERO)
	var pre_empty_rooms : Array[Room]
	var result : DirectionRoomCollection
	var move_direction : Vector2i
	if drc.is_east_least():
		move_direction = Vector2i(1, 0)
		result = move(drc.easts, move_direction)
		pre_empty_rooms = result.easts
	elif drc.is_north_least():
		move_direction = Vector2i(0, -1)
		result = move(drc.norths, move_direction)
		pre_empty_rooms = result.norths
	elif drc.is_west_least():
		move_direction = Vector2i(-1, 0)
		result = move(drc.wests, move_direction)
		pre_empty_rooms = result.wests
	else: # south
		move_direction = Vector2i(0, 1)
		result = move(drc.souths, move_direction)
		pre_empty_rooms = result.souths

	for room : Room in pre_empty_rooms:
		#var old_dest : Room = room.east
		var new_room : Room = Room.CreateRoom(room.x + move_direction.x, room.y + move_direction.y, self)
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
	assert(is_gameplay_active == false)
	%Player.position = Vector2((first_room.x * 15 + 7.5) * 64, (first_room.y * 15 + 7.5) * 64)
