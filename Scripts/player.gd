extends CharacterBody2D

class_name Player

const INITIAL_SPEED = 300.0
const MAX_SPEED = 600.0
const INITIAL_MAX_COOLDOWN = 1.75
const INITIAL_DAMAGE = 101.0
const INITIAL_MAX_HEALTH = 100.0
const INITIAL_BULLET_LIFETIME = 0.75
const INITIAL_FIRE_RESISTANCE = 1.0

var our_momentum : Vector2
var fire_resistance : float = INITIAL_FIRE_RESISTANCE
var fire_cooldown : float = 0
var fire_cooldown_max : float = INITIAL_MAX_COOLDOWN
var has_regeneration : bool = false
var current_health : float = INITIAL_MAX_HEALTH
var max_health : float = INITIAL_MAX_HEALTH
var shot_damage : float = INITIAL_DAMAGE
var current_speed : float = INITIAL_SPEED
var bullet_lifetime : float = INITIAL_BULLET_LIFETIME
var ui_layer : CanvasLayer = null
var gun_sprite : Sprite2D = null
var ui_current_health_bar : ColorRect = null
var ui_current_health_label : Label = null
var ui_current_health_max_width : float = 200
var owned_keys : Array[int]
var hand_size : int = 2
@export var reload_sounds : AudioStreamRandomizer
@export var lock_open_sound : AudioStream
@export var key_pickup_sound : AudioStream
@export var firepit_sound : AudioStream

var lock_audio_player : AudioStreamPlayer
var firepit_audio_player : AudioStreamPlayer
var firepit_sound_continue : float = 0

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
	lock_audio_player = find_child("AudioStreamPlayer_Lock") as AudioStreamPlayer
	assert(lock_audio_player)
	firepit_audio_player = find_child("AudioStreamPlayer_Fire") as AudioStreamPlayer
	assert(firepit_audio_player)

	firepit_audio_player.stream = firepit_sound
	firepit_audio_player.volume_db = -15
	$AudioStreamPlayer.stream = reload_sounds

func defered_init() -> void:
	ui_current_health_max_width = (find_child("MaxHealth") as ColorRect).custom_minimum_size.x
	set_health_bar()

func init_brand_new_game(play_state : PlayState) -> void:
	owned_keys.clear()
	current_speed = INITIAL_SPEED
	hand_size = play_state.get_initial_hand_size()
	fire_cooldown = 0
	fire_cooldown_max = INITIAL_MAX_COOLDOWN
	max_health = INITIAL_MAX_HEALTH
	current_health = max_health
	shot_damage = INITIAL_DAMAGE
	bullet_lifetime = INITIAL_BULLET_LIFETIME
	fire_resistance = INITIAL_FIRE_RESISTANCE
	has_regeneration = false
	set_health_bar()

func spawn(_room: Room, pos : Vector2) -> void:
	owned_keys.clear()
	if has_regeneration:
		current_health = min(current_health + 5, max_health)
		set_health_bar()
	fire_cooldown = 0.01
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
	if firepit_audio_player.playing:
		firepit_sound_continue = 0.15
	else:
		firepit_audio_player.play()
	var damage : float = room.fire_damage * delta / fire_resistance
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
	bullet.init(bullet_lifetime, self)
	%State_Play.add_child(bullet)
	fire_cooldown = fire_cooldown_max

func set_ui_visibility(_visible : bool) -> void:
	ui_layer.visible = _visible
	
#func _process(_delta: float) -> void:
	#queue_redraw()
#
#func _draw() -> void:
	#draw_line(to_local(global_position), get_local_mouse_position(), Color.REBECCA_PURPLE, 3)

func stop_anim() -> void:
	(find_child("AnimatedSprite2D") as AnimatedSprite2D).pause()
	
func _physics_process(delta: float) -> void:
	if firepit_sound_continue > 0:
		firepit_sound_continue -= delta
		if firepit_sound_continue <= 0:
			firepit_audio_player.stop()
			
	if %State_Play.is_gameplay_active == false:
		return
	
	#look_at(get_global_mouse_position())
	
	var anim : AnimatedSprite2D = (find_child("AnimatedSprite2D") as AnimatedSprite2D)
	if fire_cooldown >= 0:
		fire_cooldown -= delta
		if fire_cooldown < 0:
			$AudioStreamPlayer.play()
			anim.play("armed")

	if Input.is_action_pressed("fire_guns"):
		if fire_cooldown < 0:
			fire_bullet()
			anim.play("unarmed")

	var acc_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if acc_dir == Vector2.ZERO:
		var slow = (1 - delta)
		slow = slow * slow
		velocity = our_momentum * slow
		if anim.is_playing():
			anim.pause()
	else:
		velocity = (acc_dir * current_speed + our_momentum).normalized() * current_speed
		if !anim.is_playing():
			anim.play()

	move_and_slide()
	
	var collision : KinematicCollision2D = get_last_slide_collision()
	if collision:
		var enemy : Enemy = collision.get_collider() as Enemy
		if enemy:
			enemy.handle_player_collision(self, delta)
		var key : Key = collision.get_collider() as Key
		if key:
			owned_keys.append(key.lock_id)
			key.remove_from_room()
			lock_audio_player.stream = key_pickup_sound
			lock_audio_player.volume_db = -15
			lock_audio_player.play()
		var lock : Lock = collision.get_collider() as Lock
		if lock:
			var index : int = owned_keys.find(lock.room.id)
			if index != -1:
				owned_keys.remove_at(index)
				lock.remove_from_room()
				lock_audio_player.stream = lock_open_sound
				lock_audio_player.volume_db = 0
				lock_audio_player.play()
	
	our_momentum = get_position_delta() / delta

	if velocity != Vector2.ZERO:
		up_direction = Vector2.ZERO - velocity
	
	%State_Play.trigger_player_location_events(position, delta)
