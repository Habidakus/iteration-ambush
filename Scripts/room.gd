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
var play_state : PlayState
var enemies : Array[Enemy]
var enemy_count : float = 1
var fire_damage : float = 20.0
var room_mods : Array[RoomMod]
var unspent_difficulty : int = 1

var dagger_thrower_reload : float = -1
var dagger_thrower_scene : Resource = preload("res://Scene/dagger_thrower.tscn")
var dagger_thrower : DaggerThrower = null

var enemy_scene : Resource = preload("res://Scene/enemy.tscn")
var has_enemy : bool = true

var urist_scene : Resource = preload("res://Scene/urist.tscn")
var urist : Urist = null

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
var atlas_source_id_wall : int = 0
var atlas_source_id_other : int = 1
var atlas_coords_other_floor : Vector2i = Vector2i(0, 0)
var atlas_coords_other_firepit : Vector2i = Vector2i(2, 0)
var atlas_coords_other_lastroom : Vector2i = Vector2i(1, 0)

enum RoomType {
	UNDEFINED,
	Empty,
	BigFirepit,
	ManyFirepits,
	Narrow,
	Diamond,
	BigPilar,
	ManyPilars,
	Wall,
	Loop,
	LastRoom,
	FinalRoom,
}
var room_type : RoomType = RoomType.UNDEFINED

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

	match cplay_state.build_rnd.randi_range(0,5):
		0:
			room.room_type = RoomType.ManyFirepits
			room.unspent_difficulty -= 1
		1:
			room.room_type = RoomType.ManyPilars
		2:
			room.room_type = RoomType.Diamond
		3:
			room.room_type = RoomType.Narrow
		4:
			room.room_type = RoomType.BigPilar
			
	room.room_mods = RoomMod.SelectThreeMods(cplay_state.build_rnd, room)
	while room.unspent_difficulty > 0:
		room.SpendDifficulty(cplay_state.build_rnd)
		room.unspent_difficulty -= 1

	return room

static func CreateRoom(cx : int, cy : int, cplay_state : PlayState, parent : Room) -> Room:
	global_id += 1
	
	var room : Room = Room.new()
	room.x = cx
	room.y = cy
	room.id = global_id
	room.play_state = cplay_state
	room.parent_room = parent

	match cplay_state.build_rnd.randi_range(0,9):
		0:
			room.room_type = RoomType.BigFirepit
			room.unspent_difficulty -= 1
		1:
			room.room_type = RoomType.ManyFirepits
			room.unspent_difficulty -= 1
		2:
			room.room_type = RoomType.ManyPilars
		3:
			room.room_type = RoomType.BigPilar
		4:
			room.room_type = RoomType.Diamond
		5:
			room.room_type = RoomType.Narrow
		6:
			room.room_type = RoomType.Wall
		7:
			room.room_type = RoomType.Loop
		8:
			room.room_type = RoomType.Empty
	room.room_mods = RoomMod.SelectThreeMods(cplay_state.build_rnd, room)
	while room.unspent_difficulty > 0:
		room.SpendDifficulty(cplay_state.build_rnd)
		room.unspent_difficulty -= 1
	return room

func SpendDifficulty(rnd : RandomNumberGenerator) -> void:
	if play_state.last_room == self:
		return

	if play_state.first_room == self:
		return
		
	var count : int = 0
	for mod : RoomMod in room_mods:
		if mod.can_advance():
			count += 1
	if count == 0:
		print("Can't advance " + str(self))
	count = rnd.randi() % count
	for mod : RoomMod in room_mods:
		if mod.can_advance():
			if count == 0:
				mod.advance()
				return
			count -= 1
	assert(false)

func _to_string() -> String:
	var ret_val : String = "id=" + str(id) + " coord=" + str(x) + "," + str(y) + " " + str(room_type)
	return ret_val

func StopTracking(enemy : Enemy) -> void:
	play_state.killed_this_wave += 1
	var index : int = enemies.find(enemy)
	assert(index != -1)
	enemies.remove_at(index)
	
func GetParentRoom() -> Room:
	return parent_room

func CanHaveDaggerThrower() -> bool:
	if room_type == RoomType.Empty || room_type == RoomType.ManyFirepits || room_type == RoomType.BigFirepit:
		return key_id == -1
	return false

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
	unspent_difficulty += play_state.get_room_difficulty_increase()
	while unspent_difficulty > 0:
		SpendDifficulty(play_state.build_rnd)
		unspent_difficulty -= 1
	if key:
		key.queue_free()
		key = null

	if lock:
		lock.queue_free()
		lock = null
		
	if !enemies.is_empty():
		for enemy : Enemy in enemies:
			enemy.queue_free()
		enemies.clear()

	if urist:
		urist.queue_free()
		urist = null
	
	if dagger_thrower:
		dagger_thrower.queue_free()
		dagger_thrower = null

func SetAsLastRoom() -> void:
	room_type = RoomType.LastRoom

func MakeFinalRoom() -> void:
	assert(room_type == RoomType.LastRoom)
	room_type = RoomType.FinalRoom

func MakePlayerSafe() -> void:
	has_enemy = false
	if room_type == RoomType.BigFirepit || room_type == RoomType.ManyFirepits || room_type == RoomType.Loop || room_type == RoomType.Wall:
		room_type = RoomType.Empty

func DrawRoomNumber() -> void:
	var pos = play_state.get_room_central_pos(x, y)
	var font = ThemeDB.fallback_font
	play_state.draw_string(font, pos, str(id), HORIZONTAL_ALIGNMENT_CENTER, 64, 64)

func UpdatePlayerInRoom(rnd : RandomNumberGenerator) -> void:
	if has_entered == true:
		return
	
	#print("Entered room ID: " + str(id))

	play_state.player_entered_room_for_first_time(self)
	has_entered = true

	Spawn(rnd)
	WakeUp(rnd)
	if north:
		north.WakeUp(rnd)
	if south:
		south.WakeUp(rnd)
	if east:
		east.WakeUp(rnd)
	if west:
		west.WakeUp(rnd)

func WakeUp(rnd : RandomNumberGenerator) -> void:
	if has_woken:
		return

	enemy_count = 1.0
	for mod : RoomMod in room_mods:
		mod.apply_to_room(self)

	#print("Woke room ID: " + str(id))
	has_woken = true
	
	Spawn(rnd)

	for enemy : Enemy in enemies:
		#print("Waking enemy in room " + str(id))
		enemy.wake(play_state.get_player())

	if north:
		north.Spawn(rnd)
	if south:
		south.Spawn(rnd)
	if east:
		east.Spawn(rnd)
	if west:
		west.Spawn(rnd)

func Spawn(rnd : RandomNumberGenerator) -> void:
	if has_spawned:
		return

	#print("Spawn room ID: " + str(id))
	
	if room_lock_blocks != null:
		assert(lock == null)
		lock = lock_scene.instantiate()
		var our_center_pos : Vector2 = play_state.get_room_central_pos(x, y)
		var locked_room_center_pos : Vector2 = play_state.get_room_central_pos(room_lock_blocks.x, room_lock_blocks.y)
		lock.position = our_center_pos + (locked_room_center_pos - our_center_pos).normalized() * 64 * 7
		lock.init(self)
		play_state.add_child(lock)
	
	if key_id != -1:
		assert(key == null)
		key = key_scene.instantiate()
		key.position = play_state.get_room_central_pos(x, y)
		key.init(key_id, self)
		play_state.add_child(key)
	
	if dagger_thrower_reload > 0:
		dagger_thrower = dagger_thrower_scene.instantiate()
		var our_center_pos : Vector2 = play_state.get_room_central_pos(x, y)
		dagger_thrower.position = our_center_pos
		dagger_thrower.init(self, dagger_thrower_reload)
		play_state.add_child(dagger_thrower)

	if has_enemy:
		assert(enemies.is_empty())
		#print("Spawning enemy for room ID: " + str(id))
		for i in range(0, round(enemy_count)):
			var enemy : Enemy = enemy_scene.instantiate()
			enemy.position = GetSafeEnemyPlacement(rnd)
			enemy.init(id, play_state.get_player().get_shot_damage(), self)
			play_state.add_child(enemy)
			enemies.append(enemy)
	
	has_spawned = true

func AnyEnemiesHere(pos : Vector2) -> bool:
	for enemy: Enemy in enemies:
		if (enemy.position - pos).length_squared() < 64 * 64 * 1.707:
			return true
	return false

func GetSafeTeleportLocation(best_loc : Vector2, start_place : Vector2) -> Vector2:
	var best_room : Room = play_state.get_room_from_pos(best_loc)
	if best_room:
		if play_state.can_place_enemy(best_loc) && !best_room.AnyEnemiesHere(best_loc):
			return best_loc
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var attempt_loc : Vector2 = start_place + Vector2(64 * dx, 64 * dy)
				if play_state.can_place_enemy(attempt_loc) && !best_room.AnyEnemiesHere(attempt_loc):
					return attempt_loc
		return best_room.GetSafeEnemyPlacement(RandomNumberGenerator.new())
	var current_room : Room = play_state.get_room_from_pos(start_place)
	if current_room:
		return current_room.GetSafeEnemyPlacement(RandomNumberGenerator.new())
	return start_place

func GetSafeEnemyPlacement(rnd : RandomNumberGenerator) -> Vector2:
	var center : Vector2 = play_state.get_room_central_pos(x, y)
	var ret_val : Vector2 = center

	while !play_state.can_place_enemy(ret_val) || AnyEnemiesHere(ret_val):
		var dx : int = rnd.randi_range(-6, 6)
		var dy : int = rnd.randi_range(-6, 6)
		ret_val = center + Vector2(dx * 64, dy * 64)
		
	return ret_val

func SetKeyColor(color : Color) -> void:
	key_color = color

func SetLockColor(color : Color) -> void:
	lock_color = color

func KeyGrabbed() -> void:
	assert(key != null)
	var lock_room : Room = play_state.get_room_by_id(key.lock_id)
	assert(lock_room)
	lock_room.RespawnLockEnemies()
	key = null

func UpdateSpawnCount() -> void:
	play_state.spawned_this_wave += 1

func RespawnLockEnemies() -> void:
	for i in range(enemies.size(), round(enemy_count)):
		var enemy : Enemy = enemy_scene.instantiate()
		enemy.position = GetSafeEnemyPlacement(play_state.build_rnd)
		enemy.init(id, play_state.get_player().get_shot_damage(), self)
		play_state.add_child(enemy)
		enemies.append(enemy)
		enemy.wake(play_state.get_player())

func LockRemoved() -> void:
	assert(lock != null)
	lock = null

func ApplyToMaps(terrain : TileMapLayer, _objects : TileMapLayer) -> void:
	var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
	rnd.seed = id
	var baseX : int = x * size
	var baseY : int = y * size
	var width : int = 4 if room_type == RoomType.Narrow else 1
	for dx in range(0, size):
		for dy in range(0, size):
			apply_floor(terrain, baseX + dx, baseY + dy, rnd)
	for w in range(0, width):
		for i in range(0, size):
			apply_wall(terrain, baseX + i, baseY + w, rnd)
			apply_wall(terrain, baseX + i, baseY + size - (1 + w), rnd)
			if i >= width and i <= (size - (1 + width)):
				apply_wall(terrain, baseX + w, baseY + i, rnd)
				apply_wall(terrain, baseX + size - (1 + w), baseY + i, rnd)
		if north != null:
			apply_floor(terrain, baseX + 7, baseY + w, rnd)
		if west != null:
			apply_floor(terrain, baseX + w, baseY + 7, rnd)
		if south != null:
			apply_floor(terrain, baseX + 7, baseY + size - (1 + w), rnd)
		if east != null:
			apply_floor(terrain, baseX + size - (1 + w), baseY + 7, rnd)

	match room_type:
		RoomType.Wall:
			if north == null:
				for dx in range(6,9):
					for dy in range(1,12):
						apply_wall(terrain, baseX + dx, baseY + dy, rnd)
			elif south == null:
				for dx in range(6,9):
					for dy in range(3,14):
						apply_wall(terrain, baseX + dx, baseY + dy, rnd)
			elif east == null:
				for dy in range(6,9):
					for dx in range(3,14):
						apply_wall(terrain, baseX + dx, baseY + dy, rnd)
			elif west == null:
				for dy in range(6,9):
					for dx in range(1,12):
						apply_wall(terrain, baseX + dx, baseY + dy, rnd)
		RoomType.Loop:
			for dx in range(3,12):
				for dy in range(3,12):
					apply_wall(terrain, baseX + dx, baseY + dy, rnd)
		RoomType.Diamond:
			for dx in range(1, 6):
				for dy in range(1, 7 - dx):
					apply_wall(terrain, baseX + dx, baseY + dy, rnd)
					apply_wall(terrain, baseX + size - (1 + dx), baseY + dy, rnd)
					apply_wall(terrain, baseX + dx, baseY + size - (1 + dy), rnd)
					apply_wall(terrain, baseX + size - (1 + dx), baseY + size - (1 + dy), rnd)
		RoomType.LastRoom:
			for ox in range(baseX + 5, baseX + size - 5):
				for oy in range(baseY + 5, baseY + size - 5):
					terrain.set_cell(Vector2i(ox, oy), atlas_source_id_other, atlas_coords_other_lastroom)
		RoomType.FinalRoom:
			urist = urist_scene.instantiate()
			var our_center_pos : Vector2 = play_state.get_room_central_pos(x, y)
			urist.position = our_center_pos
			play_state.add_child(urist)
		RoomType.BigPilar:
			apply_pillar(terrain, baseX + 4, baseY + 4, rnd)
			apply_pillar(terrain, baseX + 9, baseY + 4, rnd)
			apply_pillar(terrain, baseX + 4, baseY + 9, rnd)
			apply_pillar(terrain, baseX + 9, baseY + 9, rnd)
		RoomType.ManyPilars:
			apply_pillar(terrain, baseX + 2, baseY + 2, rnd)
			apply_pillar(terrain, baseX + 2, baseY + 11, rnd)
			apply_pillar(terrain, baseX + 5, baseY + 5, rnd)
			apply_pillar(terrain, baseX + 8, baseY + 8, rnd)
			apply_pillar(terrain, baseX + 5, baseY + 8, rnd)
			apply_pillar(terrain, baseX + 8, baseY + 5, rnd)
			apply_pillar(terrain, baseX + 11, baseY + 2, rnd)
			apply_pillar(terrain, baseX + 11, baseY + 11, rnd)
		RoomType.BigFirepit:
			for ox in range(baseX + 4, baseX + size - 4):
				for oy in range(baseY + 4, baseY + size - 4):
					apply_firepit(terrain, ox, oy)
		RoomType.ManyFirepits:
			for dx in range(2, 6):
				for dy in range(2, 6):
					apply_firepit(terrain, baseX + dx, baseY + dy)
					apply_firepit(terrain, baseX + dx, baseY + size - (1 + dy))
					apply_firepit(terrain, baseX + size - (1 + dx), baseY + dy)
					apply_firepit(terrain, baseX + size - (1 + dx), baseY + size - (1 + dy))

func apply_pillar(terrain : TileMapLayer, px : int, py : int, rnd : RandomNumberGenerator) -> void:
	terrain.set_cell(Vector2i(px, py), atlas_source_id_wall, Vector2i(rnd.randi() % 16, 0))
	terrain.set_cell(Vector2i(px, py + 1), atlas_source_id_wall, Vector2i(rnd.randi() % 16, 0))
	terrain.set_cell(Vector2i(px + 1, py), atlas_source_id_wall, Vector2i(rnd.randi() % 16, 0))
	terrain.set_cell(Vector2i(px + 1, py + 1), atlas_source_id_wall, Vector2i(rnd.randi() % 16, 0))

func apply_wall(terrain : TileMapLayer, px : int, py : int, rnd : RandomNumberGenerator) -> void:
	terrain.set_cell(Vector2i(px, py), atlas_source_id_wall, Vector2i(rnd.randi() % 16, 0))

func apply_firepit(terrain : TileMapLayer, px : int, py : int) -> void:
	terrain.set_cell(Vector2i(px, py), atlas_source_id_other, atlas_coords_other_firepit)
	
func apply_floor(terrain : TileMapLayer, px : int, py : int, _rnd : RandomNumberGenerator) -> void:
	terrain.set_cell(Vector2i(px, py), atlas_source_id_other, atlas_coords_other_floor)

func ClearFromMaps(terrain : TileMapLayer, _objects : TileMapLayer) -> void:
	var baseX : int = x * size
	var baseY : int = y * size
	for ox in range(baseX, baseX + size):
		for oy in range(baseY, baseY + size):
			terrain.set_cell(Vector2i(ox, oy))
