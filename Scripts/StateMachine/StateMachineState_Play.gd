extends StateMachineState

class_name PlayState

const WAVES_TO_WIN = 12

var rooms : Array[Room]
var go_active : bool = false
var is_gameplay_active : bool = false
var build_seed : int = 0
var build_rnd : RandomNumberGenerator = null
var last_room_player_was_in : Room = null
var total_coins : int = 0

var killed_this_wave : int = 0
var spawned_this_wave : int = 0

var first_room : Room
var last_room : Room

enum Difficulty { Easy, Medium, Hard }
var difficulty : Difficulty = Difficulty.Easy
var waves_to_go : int = WAVES_TO_WIN

# TODO: Make global
var atlas_wall_source_id : int = 0
var atlas_other_source_id : int = 1
var floor_atlas_other : Vector2i = Vector2i(0, 0)
var last_room_atlas_other : Vector2i = Vector2i(1, 0)
var fire_pit_atlas_other : Vector2i = Vector2i(2, 0)

func _process(_delta : float) -> void:
	if go_active:
		go_active = false
		%PlayStateMachine.switch_state("PlayState_Active")
	#if is_gameplay_active:
		#queue_redraw()

#func _draw() -> void:
	#for room : Room in rooms:
		#room.DrawRoomNumber()

func player_died() -> void:
	%PlayStateMachine.switch_state("PlayState_Dead")

func restart() -> void:
	%PlayStateMachine.switch_state("PlayState_Asleep")
	var map_change_set : MapChangeSet = MapChangeSet.new()
	for room : Room in rooms:
		room.ClearFromMaps(map_change_set)
		room.ResetRoom()
	map_change_set.apply(%TerrainMap, %ObjectMap)
		
	rooms.clear()
	%Player.init_brand_new_game(self)
	waves_to_go = WAVES_TO_WIN
	go_active = false
	total_coins = 0
	is_gameplay_active = false
	first_room = null
	last_room = null
	killed_this_wave = 0
	spawned_this_wave = 0
	last_room_player_was_in = null
	our_state_machine.switch_state("State_MainMenu")

var play_minor_chord : bool = false
func set_is_minor_chord(new_minor_chord : bool) -> void:
	if new_minor_chord != play_minor_chord:
		play_minor_chord = new_minor_chord
		for child in %MusicManager.get_children(false):
			if child is NotePlayer:
				if play_minor_chord:
					(child as NotePlayer).set_to_minor()
				else:
					(child as NotePlayer).set_to_major()

func apply_tile(terrain_atlas_pos : Vector2i, source_id : int, delta : float) -> void:
	if last_room_player_was_in == null:
		return
	if source_id == atlas_other_source_id:
		if terrain_atlas_pos == last_room_atlas_other:
			%PlayStateMachine.switch_state("PlayState_LevelAdvance")
		elif terrain_atlas_pos == fire_pit_atlas_other:
			%Player.apply_fire_pit(last_room_player_was_in, delta)

func get_room_central_pos(grid_x : int, grid_y : int) -> Vector2:
	var local_pos = (%TerrainMap as TileMapLayer).map_to_local(Vector2i(grid_x * 15 + 7, grid_y * 15 + 7))
	return local_pos
	
func get_room_from_pos(pos : Vector2) -> Room:
	var map_coord : Vector2i = (%TerrainMap as TileMapLayer).local_to_map(pos)
	var grid_x : int = int(map_coord.x / 15.0)
	var grid_y : int = int(map_coord.y / 15.0)
	if map_coord.x < 0:
		grid_x -= 1
	if map_coord.y < 0:
		grid_y -= 1
	assert((map_coord.x < 0) == (grid_x < 0))
	assert((map_coord.y < 0) == (grid_y < 0))
	for room : Room in rooms:
		if room.x == grid_x && room.y == grid_y:
			return room
	return null

func get_player() -> Player:
	return %Player

func trigger_player_location_events(player_loc : Vector2, delta : float) -> void:
	
	var tml : TileMapLayer = %TerrainMap as TileMapLayer
	var map_pos : Vector2i = tml.local_to_map(player_loc)
	var atlas = tml.get_cell_atlas_coords(map_pos)
	if atlas.x != -1:
		var source_id : int = tml.get_cell_source_id(map_pos)
		apply_tile(atlas, source_id, delta)
		#var tile_data : TileData = (%TerrainMap as TileMapLayer).get_cell_tile_data(map_pos)
		#print(str(atlas) + " " + str(tile_data))
	
	if is_gameplay_active == false:
		return
	
	var grid_fx : float = (map_pos.x / 15.0)
	var grid_fy : float = (map_pos.y / 15.0)
	var grid_x : int = floor(grid_fx)
	var grid_y : int = floor(grid_fy)
	# TODO: Cache last player room so we don't have to iterate over every single one
	if last_room_player_was_in != null:
		if last_room_player_was_in.x == grid_x && last_room_player_was_in.y == grid_y:
			last_room_player_was_in.UpdatePlayerInRoom(build_rnd)
			return
			
	for room : Room in rooms:
		if room.x == grid_x && room.y == grid_y:
			room.UpdatePlayerInRoom(build_rnd)
			last_room_player_was_in = room
			return

func can_place_enemy(pos : Vector2) -> bool:
	var tml : TileMapLayer = (%TerrainMap as TileMapLayer)
	var cell = tml.local_to_map(pos)
	var source_id : int = tml.get_cell_source_id(cell)
	if source_id == atlas_other_source_id:
		var atlas : Vector2i = tml.get_cell_atlas_coords(cell)
		return atlas == floor_atlas_other
	else:
		return false

func get_room_difficulty_increase() -> int:
	match difficulty:
		Difficulty.Easy: return 1
		Difficulty.Medium: return 2
		Difficulty.Hard: return 3
	assert(false)
	return 5

func is_there_a_dagger_thrower() -> bool:
	for room : Room in rooms:
		if room.has_dagger_thrower():
			return true
	return false

func is_there_locked_room() -> bool:
	for room : Room in rooms:
		if room.key_id != -1:
			return true
	return false

func player_entered_room_for_first_time(_room : Room) -> void:
	pass

func is_player_quiet() -> bool:
	return get_player().quiet_locks

func enter_state() -> void:
	super.enter_state()
	%PlayStateMachine.switch_state("PlayState_LevelSetup")

func init_player() -> void:
	%Player.init_brand_new_game(self)

func init_map() -> void:
	Room.global_id = 0
	build_rnd = RandomNumberGenerator.new()
	build_rnd.seed = build_seed
	var r1 = Room.CreateRoom(0, 0, self, null, Room.RoomType.FirstRoom)
	var r2 = Room.CreateRoom(0, -1, self, r1, Room.RoomType.UNDEFINED)
	var r3 = Room.CreateRoom(-1, -1, self, r2, Room.RoomType.UNDEFINED)
	var r4 = Room.CreateRoom(-1, 0, self, r3, Room.RoomType.LastRoom)
	r1.MakePlayerSafe()
	r4.MakePlayerSafe()

	connect_rooms(r1, r2)
	connect_rooms(r2, r3)
	connect_rooms(r3, r4)

	rooms.append(r1)
	rooms.append(r2)
	rooms.append(r3)
	rooms.append(r4)
	
	var map_change_set : MapChangeSet = MapChangeSet.new()
	r1.ApplyToMaps(map_change_set)
	r2.ApplyToMaps(map_change_set)
	r3.ApplyToMaps(map_change_set)
	r4.ApplyToMaps(map_change_set)
	map_change_set.apply(%TerrainMap, %ObjectMap)
	
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

var available_player_mods : Array[PlayerMod]

func pick_player_mods() -> Array[PlayerMod]:
	if available_player_mods.is_empty():
		available_player_mods = PlayerMod.GetAllMods(get_player(), self)
	var mod_weights : Array
	var total_weight : float = 0
	for mod : PlayerMod in available_player_mods:
		if mod.is_available():
			mod_weights.append([mod.get_weight(), mod])
			total_weight += mod.get_weight()
	var ret_val : Array[PlayerMod]
	for i in range(0, get_player().hand_size):
		var index : float = build_rnd.randf_range(0, total_weight)
		for mp in mod_weights:
			if index < mp[0]:
				ret_val.append(mp[1])
				total_weight -= mp[0]
				mp[0] = 0
				break
			index -= mp[0]
		
	return ret_val

func get_initial_hand_size() -> int:
	match difficulty:
		Difficulty.Easy: return 4
		Difficulty.Medium: return 3
		Difficulty.Hard: return 2
	assert(false)
	return 1
	
func clean_map() -> void:
	for room : Room in rooms:
		room.ResetRoom()

func move(rooms_to_move : Array[Room], dir : Vector2i, map_change_set : MapChangeSet) -> DirectionRoomCollection:
	
	for room : Room in rooms_to_move:
		room.ClearFromMaps(map_change_set)
		#print("Moving " + str(room.x) + "," + str(room.y) + " by " + str(dir))
		room.x += dir.x
		room.y += dir.y
	var ret_val : DirectionRoomCollection = DirectionRoomCollection.new()
	for room : Room in rooms_to_move:
		room.ApplyToMaps(map_change_set)
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

func apply_player_mod(player_mod : PlayerMod) -> void:
	player_mod.selected()

func update_waves_remaining(update_label : Callable) -> void:
	waves_to_go -= 1
	update_label.call(waves_to_go)
	if waves_to_go <= 1:
		last_room.MakeFinalRoom()
		var map_change_set : MapChangeSet = MapChangeSet.new()
		last_room.ClearFromMaps(map_change_set)
		last_room.ApplyToMaps(map_change_set)
		map_change_set.apply(%TerrainMap, %ObjectMap)

func generate_map_changes() -> MapChangeSet:
	var ret_val : MapChangeSet
	if build_rnd.randi_range(0, 4) == 0:
		ret_val = generate_mutate_map_key_lock(build_rnd)
		if ret_val != null && !ret_val.is_empty():
			return ret_val
	if build_rnd.randi_range(0, 1) == 0:
		ret_val = generate_mutate_map_extrude(build_rnd)
		if ret_val != null && !ret_val.is_empty():
			return ret_val
	return generate_mutate_map_extend()

func is_empty_room(x : int, y : int) -> bool:
	for room : Room in rooms:
		if room.x == x and room.y == y:
			return false
	return true

func generate_mutate_map_key_lock(rnd : RandomNumberGenerator) -> MapChangeSet:
	var potential_east : Array[Room]
	var potential_west : Array[Room]
	var potential_north : Array[Room]
	var potential_south : Array[Room]
	for room : Room in rooms:
		if room != first_room && room != last_room && room.CanAddLock():
			if is_empty_room(room.x + 1, room.y):
				potential_east.append(room)
			if is_empty_room(room.x - 1, room.y):
				potential_west.append(room)
			if is_empty_room(room.x, room.y - 1):
				potential_north.append(room)
			if is_empty_room(room.x, room.y + 1):
				potential_south.append(room)
	var count : int = potential_east.size() + potential_west.size() + potential_north.size() + potential_south.size()
	var empty_array : MapChangeSet = null
	if count == 0:
		return empty_array
	var index : int = rnd.randi_range(0, count - 1)
	if index < potential_east.size():
		return lock_key_map(potential_east[index], Vector2i(1, 0))
	index -= potential_east.size()
	
	if index < potential_west.size():
		return lock_key_map(potential_west[index], Vector2i(-1, 0))
	index -= potential_west.size()
	
	if index < potential_north.size():
		return lock_key_map(potential_north[index], Vector2i(0, -1))
	index -= potential_north.size()
		
	if index < potential_south.size():
		return lock_key_map(potential_south[index], Vector2i(0, 1))
		
	assert(false)
	return empty_array

func generate_mutate_map_extrude(rnd : RandomNumberGenerator) -> MapChangeSet:
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
	var empty_array : MapChangeSet = null
	if count == 0:
		return empty_array
	var index : int = rnd.randi_range(0, count - 1)
	if index < potential_east.size():
		return extrude_map(potential_east[index], potential_east[index].north, Vector2i(1, 0))
	index -= potential_east.size()
	
	if index < potential_west.size():
		return extrude_map(potential_west[index], potential_west[index].north, Vector2i(-1, 0))
	index -= potential_west.size()
	
	if index < potential_north.size():
		return extrude_map(potential_north[index], potential_north[index].east, Vector2i(0, -1))
	index -= potential_north.size()
		
	if index < potential_south.size():
		return extrude_map(potential_south[index], potential_south[index].east, Vector2i(0, 1))
		
	assert(false)
	return empty_array

func get_next_room(room : Room) -> Room:
	for iter : Room in rooms:
		if iter.GetParentRoom() == room:
			return iter
	# TODO: If this triggers, fix the logic in mutate_map_key_lock()
	assert(false)
	return null

func lock_key_map(room : Room, dir : Vector2i) -> MapChangeSet:
	room.AddLock(get_next_room(room))
	var new_room : Room = Room.CreateKeyRoom(room, dir, self)
	connect_rooms(room, new_room)
	if dir == Vector2i(0, -1):
		room.north = new_room
		new_room.south = room
	elif dir == Vector2i(0, 1):
		room.south = new_room
		new_room.north = room
	rooms.append(new_room)
	var ret_val : MapChangeSet = MapChangeSet.new()
	room.ClearFromMaps(ret_val)
	new_room.ApplyToMaps(ret_val)
	room.ApplyToMaps(ret_val)
	return ret_val
	
func extrude_map(room_a : Room, room_b : Room, dir : Vector2i) -> MapChangeSet:
	var new_room_a : Room = Room.CreateRoom(room_a.x + dir.x, room_a.y + dir.y, self, null, Room.RoomType.UNDEFINED)
	var new_room_b : Room = Room.CreateRoom(room_b.x + dir.x, room_b.y + dir.y, self, null, Room.RoomType.UNDEFINED)
	if room_a.north == room_b:
		new_room_a.north = new_room_b
		new_room_b.south = new_room_a
		if room_a.room_lock_blocks == room_a.north:
			room_a.room_lock_blocks = new_room_a
		room_a.north = null
		if room_b.room_lock_blocks == room_b.south:
			room_b.room_lock_blocks = new_room_b
		room_b.south = null
	elif room_a.south == room_b:
		new_room_a.south = new_room_b
		new_room_b.north = new_room_a
		if room_a.room_lock_blocks == room_a.south:
			room_a.room_lock_blocks = new_room_a
		room_a.south = null
		if room_b.room_lock_blocks == room_b.north:
			room_b.room_lock_blocks = new_room_b
		room_b.north = null
	elif room_a.east == room_b:
		new_room_a.east = new_room_b
		new_room_b.west = new_room_a
		if room_a.room_lock_blocks == room_a.east:
			room_a.room_lock_blocks = new_room_a
		room_a.east = null
		if room_b.room_lock_blocks == room_b.west:
			room_b.room_lock_blocks = new_room_b
		room_b.west = null
	elif room_a.west == room_b:
		new_room_a.west = new_room_b
		new_room_b.east = new_room_a
		if room_a.room_lock_blocks == room_a.west:
			room_a.room_lock_blocks = new_room_a
		room_a.west = null
		if room_b.room_lock_blocks == room_b.east:
			room_b.room_lock_blocks = new_room_b
		room_b.east = null
	else:
		assert(false)

	var a_is_before_b : bool = room_b.parent_room == room_a
	if a_is_before_b:
		new_room_a.parent_room = room_a
		new_room_b.parent_room = new_room_a
		room_b.parent_room = new_room_b
	else:
		new_room_b.parent_room = room_b
		new_room_a.parent_room = new_room_b
		room_a.parent_room = new_room_a

	rooms.append(new_room_a)
	rooms.append(new_room_b)
	connect_rooms(room_a, new_room_a)
	connect_rooms(room_b, new_room_b)
	
	var ret_val : MapChangeSet = MapChangeSet.new()
	room_a.ClearFromMaps(ret_val)
	room_b.ClearFromMaps(ret_val)
	room_a.ApplyToMaps(ret_val)
	room_b.ApplyToMaps(ret_val)
	new_room_a.ApplyToMaps(ret_val)
	new_room_b.ApplyToMaps(ret_val)
	return ret_val

func generate_mutate_map_extend() -> MapChangeSet:
	var drc : DirectionRoomCollection = generate_direction_room_collection(Vector2i.ZERO)
	var pre_empty_rooms : Array[Room]
	var result : DirectionRoomCollection
	var move_direction : Vector2i
	var ret_val : MapChangeSet = MapChangeSet.new()
	if drc.is_east_least():
		move_direction = Vector2i(1, 0)
		result = move(drc.easts, move_direction, ret_val)
		pre_empty_rooms = result.easts
	elif drc.is_north_least():
		move_direction = Vector2i(0, -1)
		result = move(drc.norths, move_direction, ret_val)
		pre_empty_rooms = result.norths
	elif drc.is_west_least():
		move_direction = Vector2i(-1, 0)
		result = move(drc.wests, move_direction, ret_val)
		pre_empty_rooms = result.wests
	else: # south
		move_direction = Vector2i(0, 1)
		result = move(drc.souths, move_direction, ret_val)
		pre_empty_rooms = result.souths

	for room : Room in pre_empty_rooms:
		var new_room : Room = Room.CreateRoom(room.x + move_direction.x, room.y + move_direction.y, self, null, Room.RoomType.UNDEFINED)
		if move_direction.x > 0:
			var old_dest : Room = room.east
			new_room.west = room
			new_room.east = old_dest
			room.east = new_room
			old_dest.west = new_room
			new_room.FixParenting(room, old_dest)
		elif move_direction.x < 0:
			var old_dest : Room = room.west
			new_room.east = room
			new_room.west = old_dest
			room.west = new_room
			old_dest.east = new_room
			new_room.FixParenting(room, old_dest)
		elif move_direction.y > 0:
			var old_dest : Room = room.south
			new_room.north = room
			new_room.south = old_dest
			room.south = new_room
			old_dest.north = new_room
			new_room.FixParenting(room, old_dest)
		elif move_direction.y < 0:
			var old_dest : Room = room.north
			new_room.south = room
			new_room.north = old_dest
			room.north = new_room
			old_dest.south = new_room
			new_room.FixParenting(room, old_dest)
		new_room.ApplyToMaps(ret_val)
		rooms.append(new_room)
	return ret_val

func set_gameplay_active(active : bool) -> void:
	is_gameplay_active = active
	%Player.set_ui_visibility(active)

func get_map_global_rect() -> Rect2:
	var gr_min : Vector2 = Vector2.ZERO;
	var gr_max : Vector2 = Vector2.ZERO;
	for room : Room in rooms:
		var minx : float = room.x * 15 * 64
		if gr_min.x > minx:
			gr_min.x = minx
		var miny : float = room.y * 15 * 64
		if gr_min.y > miny:
			gr_min.y = miny	
		var maxx : float = (room.x + 1) * 15 * 64 - 1
		if gr_max.x < maxx:
			gr_max.x = maxx
		var maxy : float = (room.y + 1) * 15 * 64 - 1
		if gr_max.y < maxy:
			gr_max.y = maxy
	return Rect2(gr_min, gr_max - gr_min)

func get_room_by_id(id : int) -> Room:
	for room : Room in rooms:
		if room.id == id:
			return room
	return null
	
func drain_coins(update_coin : Callable, has_enough : Callable, is_short : Callable) -> void:
	var earned_coins : int = round(100 * %Player.compute_level_time_fraction())
	var start_coins : int = total_coins
	total_coins += earned_coins
	var end_coins : int = total_coins
	var lower_player_coins : Callable = %Player.get_lower_coins_callable()

	const time_to_move_coins = 1.5
	var tween = create_tween()
	tween.tween_method(update_coin, start_coins, end_coins, time_to_move_coins)#.set_ease(Tween.EASE_IN)
	tween.parallel()
	tween.tween_method(lower_player_coins, earned_coins, 0, time_to_move_coins)#.set_ease(Tween.EASE_IN)
	if total_coins >= 100:
		total_coins -= 100
		tween.tween_interval(0.5)
		tween.tween_callback(has_enough)
	else:
		tween.tween_interval(0.5)
		tween.tween_callback(is_short)

func move_player_to_first_room() -> void:
	assert(is_gameplay_active == false)
	%Player.spawn(first_room, get_room_central_pos(first_room.x, first_room.y), rooms.size())

func spawn_map() -> void:
	go_active = true
	killed_this_wave = 0
	spawned_this_wave = 0
	assert(is_gameplay_active == false)
	for room : Room in rooms:
		if room.key_id != -1:
			var key_color : Color = get_room_color(room.key_id)
			get_room_by_id(room.key_id).SetLockColor(key_color)
			room.SetKeyColor(key_color)

var room_color_dictionary : Dictionary
func get_room_color(room_id : int) -> Color:
	if room_color_dictionary.is_empty():
		room_color_dictionary[room_id] = Color.WHITE
		return Color.WHITE
	if room_color_dictionary.has(room_id):
		return room_color_dictionary[room_id]
	if room_color_dictionary.size() == 1: # Only has white
		room_color_dictionary[room_id] = Color.RED
		return Color.RED
	var r : int = room_color_dictionary.size() + 2
	var hue_inc : float = 1.0 / r
	var c : Color = Color.RED
	c.h = 0
	var best_color : Color = Color.BLUE
	var max_dist : float = 0
	for i in range(1, r):
		var h : float = i * hue_inc
		c.h = h
		var min_dist : float = 100.0
		for j in room_color_dictionary.keys():
			var dist : float = get_hue_distance(room_color_dictionary[j], c)
			if dist < min_dist:
				min_dist = dist
		if min_dist > max_dist:
			max_dist = min_dist
			best_color = c
	room_color_dictionary[room_id] = best_color
	return best_color

static func get_hue_distance(left : Color, right : Color) -> float:
	var left_radian : float = (left.h * 2.0 * PI)
	var right_radian : float = (right.h * 2.0 * PI)
	var left_vector : Vector2 = Vector2(cos(left_radian), sin(left_radian))
	var right_vector : Vector2 = Vector2(cos(right_radian), sin(right_radian))
	return (left_vector - right_vector).length()
