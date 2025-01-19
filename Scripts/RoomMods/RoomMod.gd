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
}

static func SelectThreeMods(rnd : RandomNumberGenerator) -> Array[RoomMod]:
	var possible : Array = [
		[rnd.randf(), Mod.Endurance],
		[rnd.randf(), Mod.Faster], 
		[rnd.randf(), Mod.Healthier],
		[rnd.randf(), Mod.MoreEnemies], 
		[rnd.randf(), Mod.Rammer],
		[rnd.randf(), Mod.Shrink],
		[rnd.randf(), Mod.Teleporter],
	]
	possible.sort_custom(func(a,b): return a[0] > b[0])
	var ret_val : Array[RoomMod]
	ret_val.append(CreateMod(possible[0][1]))
	ret_val.append(CreateMod(possible[1][1]))
	ret_val.append(CreateMod(possible[2][1]))
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
	assert(false)
	return null

func mod_name() -> String:
	return "UNDEFINED"

func can_advance() -> bool:
	assert(false)
	return false

func advance() -> void:
	assert(false)

func apply_to_room(_room : Room) -> void:
	assert(false)

func apply_to_enemy(_enemy : Enemy) -> void:
	assert(false)
