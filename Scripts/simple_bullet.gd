extends StaticBody2D

class_name SimpleBullet

var is_dead : bool = false
var lifetime : float = 4
var damage : float = 101
var movement_dir : float
var rotation_speed : float = -10.0
var speed : float = 400

var explosion_scene : Resource = preload("res://Scene/wall_hit_vfx.tscn")
@export var hit_wall_sounds : AudioStreamRandomizer
@export var hit_enemy_sounds : AudioStreamRandomizer
@export var hit_shield_sounds : AudioStreamRandomizer
@export var hit_urist_sounds : AudioStreamRandomizer

var player : Player = null

func set_damage(_damage : float) -> void:
	damage = _damage

func die(global_pos : Vector2, sound_generator : AudioStreamRandomizer, db : int) -> void:
	var explosion : CPUParticles2D = explosion_scene.instantiate()
	var audio_player : AudioStreamPlayer = null
	if sound_generator != null && sound_generator.streams_count > 0:
		audio_player = player.find_child("AudioStreamPlayer_Bullet")
		audio_player.volume_db = db
		audio_player.stream = sound_generator
		audio_player.play()
	explosion.global_position = global_pos
	explosion.emitting = true
	explosion.one_shot = true
	get_parent().add_child(explosion)
	var tween = get_parent().create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(explosion.queue_free)
	queue_free()

func init(_lifetime : float, _player : Player) -> void:
	movement_dir = rotation
	player = _player
	lifetime = _lifetime
	speed = _player.current_bullet_speed()
	add_to_group("bullet")

func collide_with_enemy(enemy: Enemy, col_glob_pos : Vector2) -> void:
	# Sometimes both the bullet will collide with the enemy, and then the enemy
	# will collide with the bullet. To stop damaging twice, we mark the bullet
	# dead on the first impact.
	if is_dead:
		return
	enemy.take_damage(damage)
	if enemy.is_dead():
		die(col_glob_pos, hit_enemy_sounds, 0)
	else:
		die(col_glob_pos, hit_shield_sounds, -20)
	is_dead = true

func _physics_process(delta : float) -> void:
	lifetime -= delta
	var move_delta : Vector2 = Vector2.RIGHT.rotated(movement_dir) * speed * delta
	if lifetime <= 0:
		#print("f=" + str(global_position))
		die(position, hit_wall_sounds, -20)
	
	rotation += delta * rotation_speed

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + move_delta * 1.05)
	query.hit_from_inside = true
	query.collision_mask = 1 + 2
	var result : Dictionary = space_state.intersect_ray(query)
	if !result.is_empty():
		var collider = result["collider"]
		var col_glob_pos : Vector2 = result["position"]
		col_glob_pos -= Vector2(20,20)
		var enemy : Enemy = collider as Enemy
		if enemy != null:
			collide_with_enemy(enemy, col_glob_pos)
			return

		var tml : TileMapLayer = collider as TileMapLayer
		if tml != null:
			die(col_glob_pos, hit_wall_sounds, -10)
			return
		
		# TODO : if we ever need to hit the portcullis, it's bitmask 32
		#var portcullis : Portcullis = collider as Portcullis
		#if portcullis != null:
			#die(col_glob_pos, hit_wall_sounds, -5)
			#return
		
		var urist : Urist = collider as Urist
		if urist != null:
			die(col_glob_pos, hit_urist_sounds, 0)
			return

		var o : Object = collider as Object
		if o != null:
			print(str(collider) + " class=" + o.get_class())
		else:
			print(str(collider) + " type=" + type_string(typeof(collider)))
		die(col_glob_pos, hit_wall_sounds, -10)
		return

	position += move_delta
