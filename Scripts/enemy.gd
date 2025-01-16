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

const BASE_HEALTH = 100.0 / 1.25
const BASE_SPEED = 300.0 / 1.25
const BASE_RAM_DAMAGE = 33

var explosion_scene : Resource = preload("res://Scene/explosion.tscn")

func take_damage(dmg : float) -> void:
	health -= dmg
	if health > 0:
		if health < player_shot_damage:
			(find_child("HealthSprite") as Sprite2D).visible = false
		return
		
	room.StopTracking(self)
	var explosion : CPUParticles2D = explosion_scene.instantiate()
	explosion.position = position
	explosion.emitting = true
	explosion.one_shot = true
	room.play_state.add_child(explosion)
	var tween = room.play_state.create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(explosion.queue_free)
	queue_free()

func init(_seed : int, difficulty : int, _player_shot_damage : float, _room : Room) -> void:
	ram_damage = BASE_RAM_DAMAGE
	player_shot_damage = _player_shot_damage
	health = BASE_HEALTH
	var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
	rnd.seed = _seed
	room = _room
	var scale_mod : float = 1
	for i in range(0, difficulty):
		match rnd.randi() % 4:
			0: speed_multiple *= 1.15
			1: health *= 1.25
			2: scale_mod *= 1.15
			3: ram_damage *= 1.25
			4: self_damage_multiple /= 1.25
	self.scale /= scale_mod
	if health > player_shot_damage:
		(find_child("HealthSprite") as Sprite2D).visible = true
	if ram_damage > BASE_RAM_DAMAGE:
		var v : float = BASE_RAM_DAMAGE / ram_damage
		modulate = Color(1, v, v)
	print("initializing enemy: " + str(self))

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
	p.take_damage(damage)
	take_damage(damage * self_damage_multiple)

func _physics_process(delta: float) -> void:
	if nav_agent == null || nav_agent.is_navigation_finished():
		return
	
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
