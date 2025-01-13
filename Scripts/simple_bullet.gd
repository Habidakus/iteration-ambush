extends StaticBody2D

var lifetime : float = 4
const SPEED : float = 400

func _ready() -> void:
	pass # Replace with function body.

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
		var enemy : Enemy = collider as Enemy
		if enemy != null:
			enemy.take_damage()
			queue_free()
			return

		var tml : TileMapLayer = collider as TileMapLayer
		if tml != null:
			queue_free()
			return

		var o : Object = collider as Object
		if o != null:
			print(str(collider) + " class=" + o.get_class())
			o.get_class()
		else:
			print(str(collider) + " type=" + type_string(typeof(collider)))
		queue_free()
		return

	position += move_delta
