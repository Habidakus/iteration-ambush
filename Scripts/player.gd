extends CharacterBody2D

class_name Player

const SPEED = 300.0

var save_vel : Vector2
var acc : Vector2
var our_momentum : Vector2
var fire_cooldown : float = 0
var fire_cooldown_max : float = 1.5
var current_health : float = 100.0
var max_health : float = 100.0
var ui_layer : CanvasLayer = null
var ui_current_health_bar : ColorRect = null
var ui_current_health_label : Label = null
var ui_current_health_max_width : float = 200

var bullet_simple_scene : Resource = preload("res://Scene/simple_bullet.tscn")

func _ready() -> void:
	ui_layer = find_child("UI") as CanvasLayer
	assert(ui_layer)
	ui_current_health_bar = find_child("CurrentHealth") as ColorRect
	assert(ui_current_health_bar)
	ui_current_health_label = find_child("HealthLabel") as Label
	assert(ui_current_health_label)

func defered_init() -> void:
	ui_current_health_max_width = (find_child("MaxHealth") as ColorRect).custom_minimum_size.x
	set_health_bar()
	
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

func fire_bullet() -> void:
	var bullet : StaticBody2D = bullet_simple_scene.instantiate()
	#bullet.global_position = self.global_position
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
	#Input.is_action_just_pressed("ui_accept"):

	#var acc : float = SPEED * _delta
		
	# Start and stop quickly
	#var v_s : float = velocity.length_squared()
	#if v_s < 100 * 100:
		#acc = (acc + 0) / 2.0

	#velocity = save_vel
	
	if %State_Play.is_gameplay_active == false:
		return
	
	look_at(get_global_mouse_position())
	
	fire_cooldown -= delta
	if Input.is_action_pressed("ui_accept"):
		if fire_cooldown <= 0:
			fire_bullet()
	
	var acc_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if acc_dir == Vector2.ZERO:
		var slow = (1 - delta)
		slow = slow * slow
		velocity = our_momentum * slow
	else:
		velocity = (acc_dir * SPEED + our_momentum).normalized() * SPEED

	#var dx : float = Input.get_axis("ui_left", "ui_right")
	#if dx != 0:
		#velocity.x = move_toward(velocity.x, SPEED * dx, acc.x)
	#else:
		#velocity.x = move_toward(velocity.x, 0, acc.x)
		#
	#var dy : float = Input.get_axis("ui_up", "ui_down")
	#if dy != 0:
		#velocity.y = move_toward(velocity.y, SPEED * dy, acc.x)
	#else:
		#velocity.y = move_toward(velocity.y, 0, acc.x)

	#print(str(velocity.length()) )

	#save_vel = velocity
	#var pre_pos = self.position

	move_and_slide()
	
	var collision : KinematicCollision2D = get_last_slide_collision()
	if collision:
		var enemy : Enemy = collision.get_collider() as Enemy
		if enemy:
			self.take_damage(enemy.get_ram_damage() * delta)
	
	our_momentum = get_position_delta() / delta

	if velocity != Vector2.ZERO:
		up_direction = Vector2.ZERO - velocity
	
	#var collision : KinematicCollision2D = move_and_collide(velocity * _delta)
	#if collision:
	
	%State_Play.trigger_player_location_events(position, delta)
