extends Object

class_name RoomMod

enum Mod {
	Endurance = 0,
	Faster = 1,
	Healthier = 2,
	MoreEnemies = 3,
	Rammer = 4,
	Shrink = 5,
	Teleporter = 6,
	DaggerThrower = 7,
}

static var unspent_points : Dictionary

static func SelectThreeMods(rnd : RandomNumberGenerator, room : Room) -> Array[RoomMod]:
	var possible : Array = [
		[rnd.randf(), Mod.Endurance],
		[rnd.randf_range(0, 0.9), Mod.Faster], 
		[rnd.randf(), Mod.Healthier],
		[rnd.randf(), Mod.MoreEnemies], 
		[rnd.randf(), Mod.Rammer],
		[rnd.randf(), Mod.Shrink],
		[rnd.randf_range(0, 0.75), Mod.Teleporter],
		[rnd.randf(), Mod.DaggerThrower],
	]
	for key in unspent_points:
		for i in range(0, possible.size()):
			if possible[i][1] == key:
				possible[i][0] += unspent_points[key]
	possible.sort_custom(func(a,b): return a[0] > b[0])
	var ret_val : Array[RoomMod]
	var index : int = 0
	while ret_val.size() < 3:
		var mod : RoomMod = CreateMod(possible[index][1])
		if mod.is_viable(room):
			ret_val.append(mod)
			unspent_points.erase(possible[index][1])
		else:
			unspent_points[possible[index][1]] = possible[index][0]
		index += 1
	
	return ret_val

static func CreateMod(modEnum : Mod) -> RoomMod:
	match modEnum:
		Mod.Endurance: return RoomMod_Endurance.new()
		Mod.Faster: return RoomMod_Faster.new()
		Mod.Healthier: return RoomMod_Healthier.new()
		Mod.MoreEnemies: return RoomMod_MoreEnemy.new()
		Mod.Rammer: return RoomMod_Rammer.new()
		Mod.Shrink: return RoomMod_Shrink.new()
		Mod.Teleporter: return RoomMod_Teleporter.new()
		Mod.DaggerThrower: return RoomMod_DaggerThrower.new()
	assert(false)
	return null


func _to_string() -> String:
	return mod_name()

func mod_name() -> String:
	return "UNDEFINED"

func can_advance() -> bool:
	assert(false)
	return false

func advance() -> void:
	assert(false)

func is_viable(_room : Room) -> bool:
	assert(false)
	return false

func apply_to_room(_room : Room) -> void:
	assert(false)

func apply_to_enemy(_enemy : Enemy) -> void:
	assert(false)
