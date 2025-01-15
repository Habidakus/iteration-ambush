extends CharacterBody2D

class_name Player

const SPEED = 300.0

var our_momentum : Vector2
var fire_cooldown : float = 0
var fire_cooldown_max : float = 1.5
var current_health : float = 100.0
var max_health : float = 100.0
var shot_damage : float = 101.0
var ui_layer : CanvasLayer = null
var gun_sprite : Sprite2D = null
var ui_current_health_bar : ColorRect = null
var ui_current_health_label : Label = null
var ui_current_health_max_width : float = 200
var owned_keys : Array[int]

var bullet_simple_scene : Resource = preload("res://Scene/simple_bullet.tscn")

func _ready() -> void:
	ui_layer = find_child("UI") as CanvasLayer
	assert(ui_layer)
	ui_current_health_bar = find_child("CurrentHealth") as ColorRect
	assert(ui_current_health_bar)
	ui_current_health_label = find_child("HealthLabel") as Label
	assert(ui_current_health_label)
	gun_sprite = find_child("Gun") as Sprite2D
	assert(gun_sprite)

func defered_init() -> void:
	ui_current_health_max_width = (find_child("MaxHealth") as ColorRect).custom_minimum_size.x
	set_health_bar()

func spawn(_room: Room, pos : Vector2) -> void:
	owned_keys.clear()
	position = pos # Vector2((room.x * 15 + 7.5) * 64, (room.y * 15 + 7.5) * 64)

func set_health_bar() -> void:
	ui_current_health_label.text = str(round(current_health)) + "/" + str(round(max_health))
	var fraction : float = current_health / max_health
	ui_current_health_bar.size.x = round(fraction * ui_current_health_max_width)

func take_damage(damage : float) -> void:
	current_health -= damage
	set_health_bar()
	if current_health <= 0:
		%State_Play.player_died()

func apply_fire_pit(room: Room, delta : float) -> void:
	var damage : float = room.fire_damage * delta
	take_damage(damage)

func get_shot_damage() -> float:
	return shot_damage

func fire_bullet() -> void:
	var bullet : StaticBody2D = bullet_simple_scene.instantiate()
	#bullet.global_position = self.global_position
	bullet.set_damage(get_shot_damage())
	bullet.global_position = to_global(to_local(global_position)) #- Vector2(20,20)
	#print("b=" + str(bullet.global_position) + "  p=" + str(global_position))
	bullet.look_at(get_global_mouse_position())
	bullet.position -= Vector2(20,20)
	bullet.position += Vector2.RIGHT.rotated(bullet.rotation) * 32.0
	%State_Play.add_child(bullet)
	fire_cooldown = fire_cooldown_max

func set_ui_visibility(_visible : bool) -> void:
	ui_layer.visible = _visible
	
#func _process(_delta: float) -> void:
	#queue_redraw()
#
#func _draw() -> void:
	#draw_line(to_local(global_position), get_local_mouse_position(), Color.REBECCA_PURPLE, 3)

func _physics_process(delta: float) -> void:
	if %State_Play.is_gameplay_active == false:
		return
	
	look_at(get_global_mouse_position())
	
	fire_cooldown -= delta
	if Input.is_action_pressed("fire_guns"):
		if fire_cooldown <= 0:
			fire_bullet()

	if fire_cooldown <= 0:
		gun_sprite.scale = Vector2.ONE
	else:
		var barrel_fraction : float = (fire_cooldown_max - max(fire_cooldown, 0)) / fire_cooldown_max
		barrel_fraction *= barrel_fraction
		gun_sprite.scale = Vector2(barrel_fraction, 1)
	
	var acc_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if acc_dir == Vector2.ZERO:
		var slow = (1 - delta)
		slow = slow * slow
		velocity = our_momentum * slow
	else:
		velocity = (acc_dir * SPEED + our_momentum).normalized() * SPEED

	move_and_slide()
	
	var collision : KinematicCollision2D = get_last_slide_collision()
	if collision:
		var enemy : Enemy = collision.get_collider() as Enemy
		if enemy:
			self.take_damage(enemy.get_ram_damage() * delta)
		var key : Key = collision.get_collider() as Key
		if key:
			owned_keys.append(key.lock_id)
			key.remove_from_room()
		var lock : Lock = collision.get_collider() as Lock
		if lock:
			var index : int = owned_keys.find(lock.room.id)
			if index != -1:
				owned_keys.remove_at(index)
				lock.remove_from_room()
	
	our_momentum = get_position_delta() / delta

	if velocity != Vector2.ZERO:
		up_direction = Vector2.ZERO - velocity
	
	%State_Play.trigger_player_location_events(position, delta)
