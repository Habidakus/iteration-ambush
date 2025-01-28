class_name MapChangeSet extends Object

var additions : Array[MapChange]
var clears : Array[Vector2i]

func set_floor(x : int, y: int) -> void:
	additions.append(MapChange.create_floor(x, y))
	#terrain.set_cell(Vector2i(px, py), atlas_source_id_other, atlas_coords_other_floor)

func set_wall(x : int, y : int, rnd : RandomNumberGenerator) -> void:
	additions.append(MapChange.create_wall(x, y, rnd))

func set_exit(x : int, y : int) -> void:
	additions.append(MapChange.create_exit(x, y))

func set_firepit(x : int, y : int) -> void:
	additions.append(MapChange.create_firepit(x, y))

func clear_cell(x : int, y : int) -> void:
	clears.append(Vector2i(x, y))

func size() -> int:
	return clears.size() + additions.size()

func apply_subset(terrain_map : TileMapLayer, object_map : TileMapLayer, count : int) -> void:
	var clears_to_remove : int = 0
	for cell : Vector2i in clears:
		terrain_map.set_cell(cell)
		count -= 1
		clears_to_remove += 1
		if count <= 0:
			clears = clears.slice(clears_to_remove)
			return
	clears.clear()
	var adds_to_remove : int = 0
	for change : MapChange in additions:
		change.apply(terrain_map, object_map)
		count -= 1
		adds_to_remove += 1
		if count <= 0:
			additions = additions.slice(adds_to_remove)
			return

func apply(terrain_map : TileMapLayer, object_map : TileMapLayer) -> void:
	for cell : Vector2i in clears:
		terrain_map.set_cell(cell)
	for change : MapChange in additions:
		change.apply(terrain_map, object_map)

func is_empty() -> bool:
	return clears.is_empty() && additions.is_empty()
