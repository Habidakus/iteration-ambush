extends Object

class_name Room

var north : Room = null
var south : Room = null
var east : Room = null
var west : Room = null
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

static func CreateRoom(cx : int, cy : int, cplay_state : PlayState) -> Room:
	global_id += 1
	
	var room : Room = Room.new()
	room.x = cx
	room.y = cy
	room.id = global_id
	room.play_state = cplay_state
	if room.id % 13 == 0:
		room.has_many_firepit = true
		room.difficulty -= 1
	elif room.id % 11 == 0:
		room.is_many_pilars = true
	elif room.id % 7 == 0:
		room.has_firepit = true
		room.difficulty -= 1
	elif room.id % 5 == 0:
		room.is_diamond = true
	elif room.id % 3 == 0:
		room.is_narrow = true
	elif room.id % 2 == 0:
		room.is_pilars = true
	return room

func ResetRoom() -> void:
	has_entered = false
	has_woken = false
	has_spawned = false
	difficulty += difficulty_increase_per_reset
	if enemy:
		enemy.queue_free()
		print("Queuing free for room #" + str(id) + " enemy")
		enemy = null

func SetAsLastRoom() -> void:
	is_last_room = true

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
		enemy.wake(play_state.get_player(), self)

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

	if has_enemy:
		assert(enemy == null)
		#print("Spawning enemy for room ID: " + str(id))
		enemy = enemy_scene.instantiate()
		enemy.position = play_state.get_room_central_pos(x, y)
		enemy.init(id, difficulty, play_state.get_player().get_shot_damage())
		play_state.add_child(enemy)
	
	has_spawned = true

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
