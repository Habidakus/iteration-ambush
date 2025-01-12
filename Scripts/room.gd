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
var source_id : int = 1
var play_state : PlayState
var enemy : Enemy = null

var enemy_scene : Resource = preload("res://Scene/enemy.tscn")
var has_enemy : bool = true

var has_entered : bool = false
var has_woken : bool = false
var has_spawned : bool = false

# TODO: Make global
var atlas_coords_wall : Vector2i = Vector2i(0, 0)
var atlas_coords_firepit : Vector2i = Vector2i(2, 0)
var atlas_coords_lastroom : Vector2i = Vector2i(1, 0)
var atlas_coords_floor : Vector2i = Vector2i(3, 0)

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
	elif room.id % 11 == 0:
		room.is_many_pilars = true
	elif room.id % 7 == 0:
		room.has_firepit = true
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
	if enemy:
		enemy.queue_free()
		print("Queuing free for room #" + str(id) + " enemy")
		enemy = null

func SetAsLastRoom() -> void:
	is_last_room = true

func UpdatePlayerInRoom() -> void:
	if has_entered == true:
		return
	
	print("Entered room ID: " + str(id))

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

	print("Woke room ID: " + str(id))
	has_woken = true
	
	Spawn()

	if enemy:
		print("Waking enemy in room " + str(id))
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
		
	print("Spawn room ID: " + str(id))

	if has_enemy:
		assert(enemy == null)
		print("Spawning enemy for room ID: " + str(id))
		enemy = enemy_scene.instantiate()
		enemy.position = play_state.get_room_central_pos(x, y)
		play_state.add_child(enemy)
	
	has_spawned = true

func ApplyToMaps(terrain : TileMapLayer, _objects : TileMapLayer) -> void:
	var baseX : int = x * size
	var baseY : int = y * size
	var width : int = 4 if is_narrow else 1
	for dx in range(0, size):
		for dy in range(0, size):
			terrain.set_cell(Vector2i(baseX + dx, baseY + dy), source_id, atlas_coords_floor)
	for w in range(0, width):
		for i in range(0, size):
			terrain.set_cell(Vector2i(baseX + i, baseY + w), source_id, atlas_coords_wall)
			terrain.set_cell(Vector2i(baseX + i, baseY + size - (1 + w)), source_id, atlas_coords_wall)
			if i >= width and i <= (size - (1 + width)):
				terrain.set_cell(Vector2i(baseX + w, baseY + i), source_id, atlas_coords_wall)
				terrain.set_cell(Vector2i(baseX + size - (1 + w), baseY + i), source_id, atlas_coords_wall)
		if north != null:
			terrain.set_cell(Vector2i(baseX + 7, baseY + w), source_id, atlas_coords_floor)
		if west != null:
			terrain.set_cell(Vector2i(baseX + w, baseY + 7), source_id, atlas_coords_floor)
		if south != null:
			terrain.set_cell(Vector2i(baseX + 7, baseY + size - (1 + w)), source_id, atlas_coords_floor)
		if east != null:
			terrain.set_cell(Vector2i(baseX + size - (1 + w), baseY + 7), source_id, atlas_coords_floor)
	if is_diamond:
		for dx in range(1, 6):
			for dy in range(1, 7 - dx):
				terrain.set_cell(Vector2i(baseX + dx, baseY + dy), source_id, atlas_coords_wall)
				terrain.set_cell(Vector2i(baseX + size - (1 + dx), baseY + dy), source_id, atlas_coords_wall)
				terrain.set_cell(Vector2i(baseX + dx, baseY + size - (1 + dy)), source_id, atlas_coords_wall)
				terrain.set_cell(Vector2i(baseX + size - (1 + dx), baseY + size - (1 + dy)), source_id, atlas_coords_wall)
	if is_last_room:
		for ox in range(baseX + 5, baseX + size - 5):
			for oy in range(baseY + 5, baseY + size - 5):
				terrain.set_cell(Vector2i(ox, oy), source_id, atlas_coords_lastroom)
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
				terrain.set_cell(Vector2i(ox, oy), source_id, atlas_coords_firepit)
	if has_many_firepit:
		for dx in range(2, 6):
			for dy in range(2, 6):
				terrain.set_cell(Vector2i(baseX + dx, baseY + dy), source_id, atlas_coords_firepit)
				terrain.set_cell(Vector2i(baseX + dx, baseY + size - (1 + dy)), source_id, atlas_coords_firepit)
				terrain.set_cell(Vector2i(baseX + size - (1 + dx), baseY + dy), source_id, atlas_coords_firepit)
				terrain.set_cell(Vector2i(baseX + size - (1 + dx), baseY + size - (1 + dy)), source_id, atlas_coords_firepit)

func apply_pillar(terrain : TileMapLayer, px : int, py : int) -> void:
	terrain.set_cell(Vector2i(px, py), source_id, atlas_coords_wall)
	terrain.set_cell(Vector2i(px, py + 1), source_id, atlas_coords_wall)
	terrain.set_cell(Vector2i(px + 1, py), source_id, atlas_coords_wall)
	terrain.set_cell(Vector2i(px + 1, py + 1), source_id, atlas_coords_wall)

func ClearFromMaps(terrain : TileMapLayer, _objects : TileMapLayer) -> void:
	var baseX : int = x * size
	var baseY : int = y * size
	for ox in range(baseX, baseX + size):
		for oy in range(baseY, baseY + size):
			terrain.set_cell(Vector2i(ox, oy))
