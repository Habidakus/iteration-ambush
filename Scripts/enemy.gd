extends CharacterBody2D

class_name Enemy

var nav_agent : NavigationAgent2D = null
var timer : Timer = null
var player : Player = null
var room : Room = null
var start_timer : bool = false
var ram_damage : float = 33
var speed_multiple : float = 1
var health : float = 100.0
var player_shot_damage : float = 101
var self_damage_multiple : float = 5.0
var teleport_cooldown : float = -1.0
var time_to_next_teleport : float = 10.0
var jailer : bool = false
var current_jail_room : Room = null

const BASE_HEALTH = 100.0 / 1.25
const BASE_SPEED = 300.0 / 1.25
const BASE_RAM_DAMAGE = 33

var color_when_charged : Color = Color.WHITE
var color_when_spent : Color = Color.WHITE

var audio_player : AudioStreamPlayer
var explosion_scene : Resource = preload("res://Scene/explosion.tscn")
var teleport_vfx_scene : Resource = preload("res://Scene/teleport_vfx.tscn")
@export var gobble_sounds : AudioStreamRandomizer
@export var death_sounds : AudioStreamRandomizer

func is_dead() -> bool:
	return health <= 0
		
func take_damage(dmg : float) -> void:
	if is_dead():
		# We've already been killed this impulse
		return
		
	health -= dmg
	if health > 0:
		if health < player_shot_damage:
			(find_child("HealthSprite") as Sprite2D).visible = false
		return
	
	audio_player.stop()

	if current_jail_room != null:
		current_jail_room.unregister_jailer(self)

	room.StopTracking(self)
	var explosion : CPUParticles2D = explosion_scene.instantiate()
	explosion.position = position
	explosion.emitting = true
	explosion.one_shot = true
	room.play_state.add_child(explosion)
	if death_sounds != null && death_sounds.streams_count > 0:
		var new_audio_player = AudioStreamPlayer.new()
		new_audio_player.bus = "FX"
		explosion.add_child(new_audio_player)
		new_audio_player.stream = death_sounds
		new_audio_player.play()
	var tween = room.play_state.create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(explosion.queue_free)
	queue_free()

func init(_seed : int, _player_shot_damage : float, _room : Room) -> void:
	ram_damage = BASE_RAM_DAMAGE
	player_shot_damage = _player_shot_damage
	health = BASE_HEALTH
	room = _room
	room.UpdateSpawnCount()
	audio_player = find_child("AudioStreamPlayer") as AudioStreamPlayer
	#var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
	#rnd.seed = _seed
	for mod : RoomMod in _room.room_mods:
		mod.apply_to_enemy(self)
	
	#var scale_mod : float = 1
	#for i in range(0, 0):
		#match rnd.randi() % 4:
			#0: speed_multiple *= 1.15
			#1: health *= 1.25
			#2: scale_mod *= 1.15
			#3: ram_damage *= 1.25
			#4: self_damage_multiple /= 1.25
	#self.scale /= scale_mod
	if health > player_shot_damage:
		(find_child("HealthSprite") as Sprite2D).visible = true
	if jailer:
		color_when_spent = Color(0, 1, 0)
		color_when_charged = Color(0, 1, 0)
		if ram_damage > BASE_RAM_DAMAGE:
			color_when_spent = Color(1, 1, 0)
			if teleport_cooldown > 0:
				color_when_charged = Color(0.5, 1, 1)
			else:
				color_when_charged = Color(1, 1, 0)
		elif teleport_cooldown > 0:
			color_when_charged = Color(0, 1, 1)
	else:
		if ram_damage > BASE_RAM_DAMAGE:
			color_when_spent = Color(1, 0, 0)
			if teleport_cooldown > 0:
				color_when_charged = Color(1, 0, 1)
			else:
				color_when_charged = Color(1, 0, 0)
		elif teleport_cooldown > 0:
			color_when_charged = Color(0, 0, 1)
	modulate = color_when_charged

func _to_string() -> String:
	var ret_val : String = "id=" + str(room.id)
	if scale != Vector2.ONE:
		ret_val += " scale=" + str(scale.x)
	if speed_multiple != 1:
		ret_val += " speed=" + str(speed_multiple)
	if health != BASE_HEALTH:
		ret_val += " hp=" + str(health)
	if ram_damage != BASE_RAM_DAMAGE:
		ret_val += " dmg=" + str(ram_damage)
	if self_damage_multiple != 5:
		ret_val += " def=" + str(5.0 / self_damage_multiple)
	if teleport_cooldown > 0:
		ret_val += " teleporting"
	if jailer:
		ret_val += " jailer"
		
	return ret_val

func tick() -> void:
	if nav_agent:
		if player:
			var vec_to_player = player.global_position - global_position
			if vec_to_player.length_squared() > 84 * 84:
				nav_agent.target_position = player.global_position
			else:
				var past_player : Vector2 = player.global_position + vec_to_player.normalized() * 64.0
				nav_agent.target_position = past_player

func wake(_player : Player) -> void:
	player = _player
	start_timer = true

func _process(_delta : float) -> void:
	if nav_agent == null:
		nav_agent = find_child("NavigationAgent2D", true) as NavigationAgent2D
		assert(nav_agent)

	if timer == null:
		timer = find_child("Timer") as Timer
		assert(timer)
		
	if start_timer:
		start_timer = false
		tick()
		timer.start()

func get_ram_damage() -> float:
	return ram_damage

func handle_player_collision(p : Player, delta: float) -> void:
	var damage : float = get_ram_damage() * delta
	p.take_damage(damage, true)
	take_damage(damage * self_damage_multiple)
	if !audio_player.playing && gobble_sounds != null && gobble_sounds.streams_count > 0:
		audio_player.stream = gobble_sounds
		audio_player.play()

func can_teleport() -> bool:
	if teleport_cooldown > 0:
		return time_to_next_teleport <= 0
	return false

func teleport(vec_to_bullet : Vector2) -> void:
	var perp : Vector2 = Vector2(vec_to_bullet.y, -vec_to_bullet.x)
	var destination : Vector2 = room.GetSafeTeleportLocation(position + vec_to_bullet - perp, position)
	if destination == position:
		return
	
	var vfx1 : CPUParticles2D = teleport_vfx_scene.instantiate()
	var vfx2 : CPUParticles2D = teleport_vfx_scene.instantiate()
	var vfx3 : CPUParticles2D = teleport_vfx_scene.instantiate()
	var vfx4 : CPUParticles2D = teleport_vfx_scene.instantiate()
	vfx1.position = position
	vfx2.position = destination
	vfx3.position = position.lerp(destination, 0.333)
	vfx4.position = position.lerp(destination, 0.666)
	vfx1.emitting = true
	vfx2.emitting = true
	vfx3.emitting = true
	vfx4.emitting = true
	vfx1.one_shot = true
	vfx2.one_shot = true
	vfx3.one_shot = true
	vfx4.one_shot = true
	room.play_state.add_child(vfx1)
	room.play_state.add_child(vfx2)
	room.play_state.add_child(vfx3)
	room.play_state.add_child(vfx4)
	var tween = room.play_state.create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(vfx1.queue_free)
	tween.tween_callback(vfx2.queue_free)
	tween.tween_callback(vfx3.queue_free)
	tween.tween_callback(vfx4.queue_free)
	
	position = destination
	time_to_next_teleport = teleport_cooldown
	adjust_color()

func adjust_color() -> void:
	if can_teleport():
		modulate = color_when_charged
	else:
		var fraction : float = time_to_next_teleport / teleport_cooldown
		fraction = sqrt(sqrt(fraction))
		modulate = color_when_charged.lerp(color_when_spent, fraction)

func _physics_process(delta: float) -> void:
	if nav_agent == null || nav_agent.is_navigation_finished():
		return
		
	if can_teleport():
		var should_teleport : Vector2 = Vector2.ZERO
		for bullet : SimpleBullet in get_tree().get_nodes_in_group("bullet"):
			var bullet_dir : Vector2 = bullet.global_position - global_position
			if bullet_dir.length_squared() < 96 * 96:
				should_teleport = bullet_dir
				break
		if should_teleport != Vector2.ZERO:
			teleport(should_teleport)
	elif teleport_cooldown > 0:
		time_to_next_teleport -= delta
		adjust_color()
	
	var axis : Vector2 = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = axis * BASE_SPEED * speed_multiple
	
	move_and_slide()
	
	var collision : KinematicCollision2D = get_last_slide_collision()
	if collision:
		var col_player : Player = collision.get_collider() as Player
		if col_player:
			handle_player_collision(col_player, delta)
		var col_bullet : SimpleBullet = collision.get_collider() as SimpleBullet
		if col_bullet:
			col_bullet.collide_with_enemy(self, collision.get_position())
	elif audio_player.playing:
		audio_player.stop()
	
	if jailer && current_jail_room == null:
		var current_room : Room = room.play_state.get_room_from_pos(position)
		var player_room : Room = room.play_state.get_room_from_pos(player.position)
		if current_room == player_room:
			if current_room.is_player_inside_portcullis(player):
				current_room.register_jailer(self)
				current_jail_room = current_room
