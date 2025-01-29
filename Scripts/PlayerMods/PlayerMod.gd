class_name PlayerMod extends Object

var player : Player = null
var play_state : PlayState = null

static func GetAllMods(_player : Player, _play_state : PlayState) -> Array[PlayerMod]:
	var ret_val : Array[PlayerMod]
	ret_val.append(PlayerMod_MoveFaster.new())
	ret_val.append(PlayerMod_FireFaster.new())
	ret_val.append(PlayerMod_Heal.new())
	ret_val.append(PlayerMod_MoreDamage.new())
	ret_val.append(PlayerMod_RaiseMaxHealth.new())
	ret_val.append(PlayerMod_LargerModSelection.new())
	ret_val.append(PlayerMod_FurtherBullets.new())
	ret_val.append(PlayerMod_FireResistance.new())
	ret_val.append(PlayerMod_ArrowResistance.new())
	ret_val.append(PlayerMod_Regeneration.new())
	ret_val.append(PlayerMod_NoSliding.new())
	ret_val.append(PlayerMod_QuietLocks.new())
	for pm : PlayerMod in ret_val:
		pm.init(_player, _play_state)
	return ret_val

func init(_player : Player, _play_state : PlayState) -> void:
	player = _player
	play_state = _play_state

func get_title() -> String:
	assert(false)
	return ""

func get_description() -> String:
	assert(false)
	return ""

func is_available() -> bool:
	assert(false)
	return false

func get_weight() -> float:
	assert(false)
	return 0.0

func selected() -> void:
	assert(false)
