class_name Portcullis extends StaticBody2D

var dir : Vector2 = Vector2.RIGHT
const gate_speed : float = 0.1666

func _ready() -> void:
	var dest_scale : Vector2 = Vector2.ONE
	if dir == Vector2.RIGHT || dir == Vector2.LEFT:
		position += Vector2(27, 0) * dir
		scale = Vector2(0, 1)
		if dir == Vector2.LEFT:
			dest_scale = Vector2(-1, 1)
	elif dir == Vector2.UP || dir == Vector2.DOWN:
		position += Vector2(0, 27) * dir
		scale = Vector2(1, 0)
		if dir == Vector2.DOWN:
			dest_scale = Vector2(1, -1)
	else:
		assert(false)
	var tree : SceneTree = get_tree()
	if tree != null:
		var tween : Tween = tree.create_tween()
		tween.tween_property(self, "scale", dest_scale, gate_speed)

func remove() -> void:
	var dest_scale : Vector2
	if dir == Vector2.RIGHT || dir == Vector2.LEFT:
		dest_scale = Vector2(0, 1)
	elif dir == Vector2.UP || dir == Vector2.DOWN:
		dest_scale = Vector2(1, 0)
	else:
		assert(false)
	var tree : SceneTree = get_tree()
	if tree != null:
		var tween : Tween = tree.create_tween()
		tween.tween_property(self, "scale", dest_scale, gate_speed)
		tween.tween_callback(self.queue_free)
