extends StaticBody2D

var lifetime : float = 4
var damage : float = 101
const SPEED : float = 400

var explosion_scene : Resource = preload("res://Scene/wall_hit_vfx.tscn")

func _ready() -> void:
	pass # Replace with function body.

func set_damage(_damage : float) -> void:
	damage = _damage

func die(global_pos : Vector2) -> void:
	var explosion : CPUParticles2D = explosion_scene.instantiate()
	explosion.global_position = global_pos
	explosion.emitting = true
	explosion.one_shot = true
	get_parent().add_child(explosion)
	var tween = get_parent().create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(explosion.queue_free)
	queue_free()

func _process(_delta: float) -> void:
	pass

func _physics_process(delta : float) -> void:
	lifetime -= delta
	var move_delta : Vector2 = Vector2.RIGHT.rotated(rotation) * SPEED * delta
	if lifetime <= 0:
		#print("f=" + str(global_position))
		queue_free()

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
			enemy.take_damage(damage)
			die(col_glob_pos)
			return

		var tml : TileMapLayer = collider as TileMapLayer
		if tml != null:
			die(col_glob_pos)
			return

		var o : Object = collider as Object
		if o != null:
			print(str(collider) + " class=" + o.get_class())
		else:
			print(str(collider) + " type=" + type_string(typeof(collider)))
		die(col_glob_pos)
		return

	position += move_delta
