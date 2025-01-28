class_name MapChange extends Object

var cell_coord : Vector2i
var source_id : int
var atlas_coord : Vector2i

# TODO: Make global
const atlas_source_id_wall : int = 0
const atlas_source_id_other : int = 1
const atlas_coords_other_floor : Vector2i = Vector2i(0, 0)
const atlas_coords_other_firepit : Vector2i = Vector2i(2, 0)
const atlas_coords_other_lastroom : Vector2i = Vector2i(1, 0)

static func create_floor(x : int, y : int) -> MapChange:
	var ret_val : MapChange = MapChange.new()
	ret_val.cell_coord = Vector2i(x, y)
	ret_val.atlas_coord = atlas_coords_other_floor
	ret_val.source_id = atlas_source_id_other
	return ret_val
static func create_wall(x : int, y : int, rnd : RandomNumberGenerator) -> MapChange:
	var ret_val : MapChange = MapChange.new()
	ret_val.cell_coord = Vector2i(x, y)
	ret_val.atlas_coord = Vector2i(rnd.randi() % 16, 0)
	ret_val.source_id = atlas_source_id_wall
	return ret_val
static func create_exit(x : int, y : int) -> MapChange:
	var ret_val : MapChange = MapChange.new()
	ret_val.cell_coord = Vector2i(x, y)
	ret_val.atlas_coord = atlas_coords_other_lastroom
	ret_val.source_id = atlas_source_id_other
	return ret_val
static func create_firepit(x : int, y : int) -> MapChange:
	var ret_val : MapChange = MapChange.new()
	ret_val.cell_coord = Vector2i(x, y)
	ret_val.atlas_coord = atlas_coords_other_firepit
	ret_val.source_id = atlas_source_id_other
	return ret_val


func apply(terrain_map : TileMapLayer, _object_map : TileMapLayer) -> void:
	terrain_map.set_cell(cell_coord, source_id, atlas_coord)
