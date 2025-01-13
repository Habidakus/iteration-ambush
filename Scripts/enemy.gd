extends CharacterBody2D

class_name Enemy

var nav_agent : NavigationAgent2D = null
var timer : Timer = null
var player : Player = null
var room : Room = null
var start_timer : bool = false
var ram_damage : float = 33

const SPEED = 300.0

var explosion_scene : Resource = preload("res://Scene/explosion.tscn")

func _ready() -> void:
	pass

func take_damage() -> void:
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

func tick() -> void:
	if nav_agent:
		if player:
			nav_agent.target_position = player.global_position

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
	if nav_agent.is_navigation_finished():
		return
	
	var axis : Vector2 = to_local(nav_agent.get_next_path_position()).normalized()
	#print("enemy moving " + str(axis))
	velocity = axis * SPEED
	
	move_and_slide()
	
	var collision : KinematicCollision2D = get_last_slide_collision()
	if collision:
		var col_player : Player = collision.get_collider() as Player
		if col_player:
			col_player.take_damage(get_ram_damage() * delta)
