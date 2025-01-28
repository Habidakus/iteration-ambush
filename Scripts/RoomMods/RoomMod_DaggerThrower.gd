class_name RoomMod_DaggerThrower extends RoomMod

var times_applied : int = 0
var times_advanced : int = 0
var multiple : float = 1.25
var reload_speed : float = 3.75
const MIN_RELOAD_SPEED : float = 1
var damage : float = 20
const MAX_DAMAGE : float = 50
var distance : float = 60 * 15 / 2.25
const MAX_DISTANCE : float = 60 * 15 * 1.25
var dagger_speed : float = 300
const MAX_DAGGER_SPEED : float = 500

func mod_name() -> String:
	return "Dagger Thrower"
	
func can_advance() -> bool:
	return reload_speed > MIN_RELOAD_SPEED && distance < MAX_DISTANCE && damage < MAX_DAMAGE && dagger_speed < MAX_DAGGER_SPEED

func advance() -> void:
	times_advanced += 1

func is_viable(room : Room) -> bool:
	return room.CanHaveDaggerThrower()

func advance_reload_speed() -> void:
	reload_speed /= multiple
	reload_speed = max(MIN_RELOAD_SPEED, reload_speed)

func advance_distance() -> void:
	distance *= multiple
	distance = min(MAX_DISTANCE, distance)

func advance_damage() -> void:
	damage *= multiple
	damage = min(MAX_DAMAGE, damage)

func advance_speed() -> void:
	dagger_speed *= multiple
	dagger_speed = min(MAX_DAGGER_SPEED, dagger_speed)

func update_stats(room_seed : int) -> void:
	var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
	rnd.seed = room_seed
	var should_apply : Array[Callable]
	if reload_speed / multiple >= MIN_RELOAD_SPEED:
		should_apply.append(Callable(self, "advance_reload_speed"))
	if distance * multiple <= MAX_DISTANCE:
		should_apply.append(Callable(self, "advance_distance"))
	if damage * multiple <= MAX_DAMAGE:
		should_apply.append(Callable(self, "advance_damage"))
	if dagger_speed * multiple <= MAX_DAGGER_SPEED:
		should_apply.append(Callable(self, "advance_speed"))
	if !should_apply.is_empty():
		should_apply[rnd.randi() % should_apply.size()].call()
		return
	# All of the values are near max... we can still push some a little bit
	if reload_speed >= MIN_RELOAD_SPEED:
		should_apply.append(Callable(self, "advance_reload_speed"))
	if distance <= MAX_DISTANCE:
		should_apply.append(Callable(self, "advance_distance"))
	if damage <= MAX_DAMAGE:
		should_apply.append(Callable(self, "advance_damage"))
	if dagger_speed <= MAX_DAGGER_SPEED:
		should_apply.append(Callable(self, "advance_speed"))
	if !should_apply.is_empty():
		should_apply[rnd.randi() % should_apply.size()].call()
		return
	print("Could not advance dagger thrower")

func apply_to_room(room : Room) -> void:
	while times_applied < times_advanced:
		times_applied += 1
		update_stats(room.id + times_applied)
	room.dagger_thrower_reload = reload_speed
	room.dagger_thrower_damage = damage
	room.dagger_thrower_distance = distance
	room.dagger_thrower_speed = dagger_speed

func apply_to_enemy(_enemy : Enemy) -> void:
	pass
