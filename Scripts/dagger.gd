extends StaticBody2D

class_name Dagger

var is_dead : bool = false
var max_distance : float = 64 * 15 / 2.0
var damage : float = 25
var movement_dir : float
var speed : float = 400
var player : Player = null
var dagger_thrower : DaggerThrower = null

var explosion_scene : Resource = preload("res://Scene/wall_hit_vfx.tscn")
@export var hit_wall_sounds : AudioStreamRandomizer
@export var hit_player_sounds : AudioStreamRandomizer

func die(global_pos : Vector2, sound_generator : AudioStreamRandomizer, db : int) -> void:
	var explosion : CPUParticles2D = explosion_scene.instantiate()
	var audio_player : AudioStreamPlayer = null
	if sound_generator != null && sound_generator.streams_count > 0:
		audio_player = player.find_child("AudioStreamPlayer_Bullet")
		audio_player.volume_db = db
		audio_player.pitch_scale = 0.5
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

func init(_player : Player, thrower : DaggerThrower) -> void:
	movement_dir = rotation
	player = _player
	dagger_thrower = thrower
	speed = dagger_thrower.dagger_speed
	damage = dagger_thrower.dagger_damage
	max_distance = dagger_thrower.max_dagger_distance

func collide_with_player(_player: Player, _col_glob_pos : Vector2) -> void:
	if is_dead:
		return
	_player.take_damage(damage / _player.arrow_resistance, true)
	is_dead = true
	queue_free()

func _physics_process(delta : float) -> void:
	var move_delta : Vector2 = Vector2.RIGHT.rotated(movement_dir) * speed * delta
	max_distance -= move_delta.length()
	if max_distance <= 0:
		#print("f=" + str(global_position))
		die(position, hit_wall_sounds, -20)

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + move_delta * 1.05)
	query.hit_from_inside = true
	query.collision_mask = 1 + 4 # Walls & Players
	if dagger_thrower != null:
		query.exclude.append(dagger_thrower.get_rid())
	var result : Dictionary = space_state.intersect_ray(query)
	if !result.is_empty():
		var collider = result["collider"]
		var col_glob_pos : Vector2 = result["position"]
		col_glob_pos -= Vector2(20,20)
		var _player : Player = collider as Player
		if _player != null:
			collide_with_player(_player, col_glob_pos)
			return

		var tml : TileMapLayer = collider as TileMapLayer
		if tml != null:
			die(col_glob_pos, hit_wall_sounds, -10)
			return
		
		var ghost : Enemy = collider as Enemy
		if ghost != null:
			# We go right through ghosts
			position += move_delta
			return
		
		var lock : Lock = collider as Lock
		if lock != null:
			return
		
		var dt : DaggerThrower = collider as DaggerThrower
		if dt != null:
			position += move_delta
			return

		var o : Object = collider as Object
		if o != null:
			print("Dagger hits: " + str(collider) + " class=" + o.get_class())
		else:
			print("Dagger hits: " + str(collider) + " type=" + type_string(typeof(collider)))
		die(col_glob_pos, hit_wall_sounds, -10)
		return

	position += move_delta
