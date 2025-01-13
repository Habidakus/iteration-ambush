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

const BASE_HEALTH = 100.0
const BASE_SPEED = 300.0
const BASE_RAM_DAMAGE = 33

var explosion_scene : Resource = preload("res://Scene/explosion.tscn")

func take_damage(dmg : float) -> void:
	health -= dmg
	if health > 0:
		return
		
	room.enemy = null
	var explosion : CPUParticles2D = explosion_scene.instantiate()
	explosion.position = position
	explosion.emitting = true
	explosion.one_shot = true
	room.play_state.add_child(explosion)
	var tween = room.play_state.create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(explosion.queue_free)
	queue_free()

func init(_seed : int, difficulty : int) -> void:
	ram_damage = BASE_RAM_DAMAGE
	health = BASE_HEALTH
	var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
	rnd.seed = _seed
	var scale_mod : float = 1
	for i in range(0, difficulty):
		match rnd.randi() % 4:
			0: speed_multiple *= 1.25
			1: health *= 1.25
			2: scale_mod *= 1.25
			3: ram_damage *= 1.25
	self.scale /= scale_mod
	if health > BASE_HEALTH:
		(find_child("HealthSprite") as Sprite2D).visible = true
	if ram_damage > BASE_RAM_DAMAGE:
		(find_child("DamageSprite") as Sprite2D).visible = true

func tick() -> void:
	if nav_agent:
		if player:
			var vec_to_player = player.global_position - global_position
			if vec_to_player.length_squared() > 84 * 84:
				nav_agent.target_position = player.global_position
			else:
				var past_player : Vector2 = player.global_position + vec_to_player.normalized() * 64.0
				nav_agent.target_position = past_player

func wake(_player : Player, _room : Room) -> void:
	player = _player
	room = _room
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

func _physics_process(delta: float) -> void:
	if nav_agent == null || nav_agent.is_navigation_finished():
		return
	
	var axis : Vector2 = to_local(nav_agent.get_next_path_position()).normalized()
	#print("enemy moving " + str(axis))
	velocity = axis * BASE_SPEED * speed_multiple
	
	move_and_slide()
	
	var collision : KinematicCollision2D = get_last_slide_collision()
	if collision:
		var col_player : Player = collision.get_collider() as Player
		if col_player:
			col_player.take_damage(get_ram_damage() * delta)
