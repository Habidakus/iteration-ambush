extends Object

class_name Room

var north : Room = null
var south : Room = null
var east : Room = null
var west : Room = null
var x : int
var y : int
var size : int = 15
var source_id : int = 1
var atlas_coords : Vector2i = Vector2i(0, 0)

func ApplyToMaps(terrain : TileMapLayer, _objects : TileMapLayer) -> void:
	var baseX : int = x * size
	var baseY : int = y * size
	for i in range(0, size):
		terrain.set_cell(Vector2i(baseX + i, baseY), source_id, atlas_coords)
		terrain.set_cell(Vector2i(baseX + i, baseY + size - 1), source_id, atlas_coords)
		if i != 0 and i != size - 1:
			terrain.set_cell(Vector2i(baseX, baseY + i), source_id, atlas_coords)
			terrain.set_cell(Vector2i(baseX + size - 1, baseY + i), source_id, atlas_coords)
	if north != null:
		terrain.set_cell(Vector2i(baseX + 7, baseY))
	if west != null:
		terrain.set_cell(Vector2i(baseX, baseY + 7))
	if south != null:
		terrain.set_cell(Vector2i(baseX + 7, baseY + size - 1))
	if east != null:
		terrain.set_cell(Vector2i(baseX + size - 1, baseY + 7))

func ClearFromMaps(terrain : TileMapLayer, _objects : TileMapLayer) -> void:
	var baseX : int = x * size
	var baseY : int = y * size
	for ox in range(baseX, baseX + size):
		for oy in range(baseY, baseY + size):
			terrain.set_cell(Vector2i(ox, oy))
