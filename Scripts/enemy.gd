extends CharacterBody2D

class_name Enemy

var nav_agent : NavigationAgent2D = null
var timer : Timer = null
var player : Player = null
var room : Room = null
var start_timer : bool = false

const SPEED = 300.0

func _ready() -> void:
	pass

func take_damage() -> void:
	room.enemy = null
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

func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var axis : Vector2 = to_local(nav_agent.get_next_path_position()).normalized()
	#print("enemy moving " + str(axis))
	velocity = axis * SPEED
	
	move_and_slide()
