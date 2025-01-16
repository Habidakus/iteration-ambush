extends Object

class_name Room

var north : Room = null
var south : Room = null
var east : Room = null
var west : Room = null
var parent_room : Room = null
var x : int
var y : int
var id : int
var size : int = 15
var atlas_source_id_floor : int = 0
var atlas_source_id_other : int = 1
var play_state : PlayState
var enemy : Enemy = null
var fire_damage : float = 20.0
var difficulty : int = 1
var difficulty_increase_per_reset : int = 2

var enemy_scene : Resource = preload("res://Scene/enemy.tscn")
var has_enemy : bool = true

var key_scene : Resource = preload("res://Scene/key.tscn")
var key : Key = null
var key_id : int = -1
var key_color : Color = Color.WHITE
var lock_scene : Resource = preload("res://Scene/lock.tscn")
var lock : Lock = null
var room_lock_blocks : Room = null
var lock_color : Color = Color.WHITE

var has_entered : bool = false
var has_woken : bool = false
var has_spawned : bool = false

# TODO: Make global
var atlas_coords_other_wall : Vector2i = Vector2i(0, 0)
var atlas_coords_other_firepit : Vector2i = Vector2i(2, 0)
var atlas_coords_other_lastroom : Vector2i = Vector2i(1, 0)
#var atlas_coords_other_floor : Vector2i = Vector2i(3, 0)

# TODO: No, repalce with enum
var has_firepit : bool = false
var has_many_firepit : bool = false
var is_narrow : bool = false
var is_diamond : bool = false
var is_pilars : bool = false
var is_many_pilars : bool = false
var is_last_room : bool = false

static var global_id : int = 0

static func CreateKeyRoom(clock_room : Room, dir : Vector2i, cplay_state : PlayState) -> Room:
	global_id += 1

	var room : Room = Room.new()
	room.x = clock_room.x + dir.x
	room.y = clock_room.y + dir.y
	room.id = global_id
	room.play_state = cplay_state
	room.key_id = clock_room.id
	room.parent_room = clock_room

	match cplay_state.build_rnd.randi_range(0,10):
		0:
			room.has_many_firepit = true
			room.difficulty -= 1
		1:
			room.is_many_pilars = true
		2,3:
			room.is_diamond = true
		4,5:
			room.is_narrow = true
		6,7:
			room.is_pilars = true

	print("Creating room: " + str(room))
	return room

func _to_string() -> String:
	var ret_val : String = "id=" + str(id) + " diff=" + str(difficulty) + " coord=" + str(x) + "," + str(y)
	if has_many_firepit:
		ret_val += " fire=4"
	if has_firepit:
		ret_val += " fire=1"
	if is_pilars:
		ret_val += " pillar=1"
	if is_many_pilars:
		ret_val += " pillar=many"
	if is_diamond:
		ret_val += " diamond"
	if is_narrow:
		ret_val += " narrow"
	return ret_val

static func CreateRoom(cx : int, cy : int, cplay_state : PlayState, parent : Room) -> Room:
	global_id += 1
	
	var room : Room = Room.new()
	room.x = cx
	room.y = cy
	room.id = global_id
	room.play_state = cplay_state
	room.parent_room = parent

	match cplay_state.build_rnd.randi_range(0,11):
		0:
			room.has_many_firepit = true
			room.difficulty -= 1
		1:
			room.is_many_pilars = true
		2,3:
			room.is_diamond = true
		4,5:
			room.is_narrow = true
		6,7:
			room.is_pilars = true
		8,9:
			room.has_firepit = true
			room.difficulty -= 1

	print("Creating room: " + str(room))
	return room

func GetParentRoom() -> Room:
	return parent_room

func FixParenting(possible_parent_a : Room, possible_parent_b : Room) -> void:
	if possible_parent_a.parent_room == possible_parent_b:
		parent_room = possible_parent_b
		possible_parent_a.parent_room = self
	elif possible_parent_b.parent_room == possible_parent_a:
		parent_room = possible_parent_a
		possible_parent_b.parent_room = self
	else:
		assert(false)

func CanAddLock() -> bool:
	if room_lock_blocks != null:
		return false
	if key_id != -1:
		return false
	var access_count : int = 0
	if north != null:
		access_count += 1
	if south != null:
		access_count += 1
	if west != null:
		access_count += 1
	if east != null:
		access_count += 1
	return access_count == 2

func AddLock(next_room : Room) -> void:
	room_lock_blocks = next_room

func ResetRoom() -> void:
	has_entered = false
	has_woken = false
	has_spawned = false
	difficulty += difficulty_increase_per_reset
	if key:
		key.queue_free()
		print("Queuing free for room #" + str(id) + " key to room #" + str(key_id) + "'s lock")
		key = null

	if lock:
		lock.queue_free()
		print("Queuing free for room #" + str(id) + " lock")
		lock = null
		
	if enemy:
		enemy.queue_free()
		enemy = null

func SetAsLastRoom() -> void:
	is_last_room = true

func MakePlayerSafe() -> void:
	has_enemy = false
	has_firepit = false
	has_many_firepit = false

func DrawRoomNumber() -> void:
	var pos = play_state.get_room_central_pos(x, y)
	var font = ThemeDB.fallback_font
	play_state.draw_string(font, pos, str(id), HORIZONTAL_ALIGNMENT_CENTER, 64, 64)

func UpdatePlayerInRoom() -> void:
	if has_entered == true:
		return
	
	#print("Entered room ID: " + str(id))

	play_state.player_entered_room_for_first_time(self)
	has_entered = true

	Spawn()
	WakeUp()
	if north:
		north.WakeUp()
	if south:
		south.WakeUp()
	if east:
		east.WakeUp()
	if west:
		west.WakeUp()

func WakeUp() -> void:
	if has_woken:
		return

	#print("Woke room ID: " + str(id))
	has_woken = true
	
	Spawn()

	if enemy:
		#print("Waking enemy in room " + str(id))
		enemy.wake(play_state.get_player())

	if north:
		north.Spawn()
	if south:
		south.Spawn()
	if east:
		east.Spawn()
	if west:
		west.Spawn()

func Spawn() -> void:
	if has_spawned:
		return
		
	#print("Spawn room ID: " + str(id))
	
	if room_lock_blocks != null:
		assert(lock == null)
		lock = lock_scene.instantiate()
		var our_center_pos : Vector2 = play_state.get_room_central_pos(x, y)
		var locked_room_center_pos : Vector2 = play_state.get_room_central_pos(room_lock_blocks.x, room_lock_blocks.y)
		lock.position = our_center_pos + (locked_room_center_pos - our_center_pos).normalized() * 64 * 6
		lock.init(self)
		play_state.add_child(lock)
	
	if key_id != -1:
		assert(key == null)
		key = key_scene.instantiate()
		key.position = play_state.get_room_central_pos(x, y)
		key.init(key_id, self)
		play_state.add_child(key)

	if has_enemy:
		assert(enemy == null)
		#print("Spawning enemy for room ID: " + str(id))
		enemy = enemy_scene.instantiate()
		enemy.position = play_state.get_room_central_pos(x, y)
		enemy.init(id, difficulty, play_state.get_player().get_shot_damage(), self)
		play_state.add_child(enemy)
	
	has_spawned = true

func SetKeyColor(color : Color) -> void:
	key_color = color

func SetLockColor(color : Color) -> void:
	lock_color = color

func KeyGrabbed() -> void:
	assert(key != null)
	key = null

func LockRemoved() -> void:
	assert(lock != null)
	lock = null

func ApplyToMaps(terrain : TileMapLayer, _objects : TileMapLayer) -> void:
	var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
	rnd.seed = id
	var baseX : int = x * size
	var baseY : int = y * size
	var width : int = 4 if is_narrow else 1
	for dx in range(0, size):
		for dy in range(0, size):
			apply_floor(terrain, baseX + dx, baseY + dy, rnd)
	for w in range(0, width):
		for i in range(0, size):
			terrain.set_cell(Vector2i(baseX + i, baseY + w), atlas_source_id_other, atlas_coords_other_wall)
			terrain.set_cell(Vector2i(baseX + i, baseY + size - (1 + w)), atlas_source_id_other, atlas_coords_other_wall)
			if i >= width and i <= (size - (1 + width)):
				terrain.set_cell(Vector2i(baseX + w, baseY + i), atlas_source_id_other, atlas_coords_other_wall)
				terrain.set_cell(Vector2i(baseX + size - (1 + w), baseY + i), atlas_source_id_other, atlas_coords_other_wall)
		if north != null:
			apply_floor(terrain, baseX + 7, baseY + w, rnd)
		if west != null:
			apply_floor(terrain, baseX + w, baseY + 7, rnd)
		if south != null:
			apply_floor(terrain, baseX + 7, baseY + size - (1 + w), rnd)
		if east != null:
			apply_floor(terrain, baseX + size - (1 + w), baseY + 7, rnd)
	if is_diamond:
		for dx in range(1, 6):
			for dy in range(1, 7 - dx):
				terrain.set_cell(Vector2i(baseX + dx, baseY + dy), atlas_source_id_other, atlas_coords_other_wall)
				terrain.set_cell(Vector2i(baseX + size - (1 + dx), baseY + dy), atlas_source_id_other, atlas_coords_other_wall)
				terrain.set_cell(Vector2i(baseX + dx, baseY + size - (1 + dy)), atlas_source_id_other, atlas_coords_other_wall)
				terrain.set_cell(Vector2i(baseX + size - (1 + dx), baseY + size - (1 + dy)), atlas_source_id_other, atlas_coords_other_wall)
	if is_last_room:
		for ox in range(baseX + 5, baseX + size - 5):
			for oy in range(baseY + 5, baseY + size - 5):
				terrain.set_cell(Vector2i(ox, oy), atlas_source_id_other, atlas_coords_other_lastroom)
	if is_pilars:
		apply_pillar(terrain, baseX + 4, baseY + 4)
		apply_pillar(terrain, baseX + 9, baseY + 4)
		apply_pillar(terrain, baseX + 4, baseY + 9)
		apply_pillar(terrain, baseX + 9, baseY + 9)
	if is_many_pilars:
		apply_pillar(terrain, baseX + 2, baseY + 2)
		apply_pillar(terrain, baseX + 2, baseY + 11)
		apply_pillar(terrain, baseX + 5, baseY + 5)
		apply_pillar(terrain, baseX + 8, baseY + 8)
		apply_pillar(terrain, baseX + 5, baseY + 8)
		apply_pillar(terrain, baseX + 8, baseY + 5)
		apply_pillar(terrain, baseX + 11, baseY + 2)
		apply_pillar(terrain, baseX + 11, baseY + 11)
	if has_firepit:
		for ox in range(baseX + 4, baseX + size - 4):
			for oy in range(baseY + 4, baseY + size - 4):
				terrain.set_cell(Vector2i(ox, oy), atlas_source_id_other, atlas_coords_other_firepit)
	if has_many_firepit:
		for dx in range(2, 6):
			for dy in range(2, 6):
				terrain.set_cell(Vector2i(baseX + dx, baseY + dy), atlas_source_id_other, atlas_coords_other_firepit)
				terrain.set_cell(Vector2i(baseX + dx, baseY + size - (1 + dy)), atlas_source_id_other, atlas_coords_other_firepit)
				terrain.set_cell(Vector2i(baseX + size - (1 + dx), baseY + dy), atlas_source_id_other, atlas_coords_other_firepit)
				terrain.set_cell(Vector2i(baseX + size - (1 + dx), baseY + size - (1 + dy)), atlas_source_id_other, atlas_coords_other_firepit)

func apply_pillar(terrain : TileMapLayer, px : int, py : int) -> void:
	terrain.set_cell(Vector2i(px, py), atlas_source_id_other, atlas_coords_other_wall)
	terrain.set_cell(Vector2i(px, py + 1), atlas_source_id_other, atlas_coords_other_wall)
	terrain.set_cell(Vector2i(px + 1, py), atlas_source_id_other, atlas_coords_other_wall)
	terrain.set_cell(Vector2i(px + 1, py + 1), atlas_source_id_other, atlas_coords_other_wall)

func apply_floor(terrain : TileMapLayer, px : int, py : int, rnd : RandomNumberGenerator) -> void:
	terrain.set_cell(Vector2i(px, py), atlas_source_id_floor, Vector2i(rnd.randi() % 16, 0))

func ClearFromMaps(terrain : TileMapLayer, _objects : TileMapLayer) -> void:
	var baseX : int = x * size
	var baseY : int = y * size
	for ox in range(baseX, baseX + size):
		for oy in range(baseY, baseY + size):
			terrain.set_cell(Vector2i(ox, oy))
