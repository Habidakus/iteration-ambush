extends StateMachineState

func enter_state() -> void:
	super.enter_state()
	var zoom_camera : Camera2D = %PlayStateMachine/ZoomCamera as Camera2D
	var player_camera : Camera2D = %Player.get_camera()
	var map_global_rect : Rect2 = our_state_machine.get_play_state().get_map_global_rect()
	map_global_rect.position -= Vector2(64 * 15, 64 * 15)
	map_global_rect.size += Vector2(64 * 15 * 2, 64 * 15 * 2)
	zoom_camera.global_position = player_camera.global_position
	zoom_camera.offset = player_camera.offset
	zoom_camera.zoom = player_camera.zoom
	zoom_camera.scale = player_camera.scale
	zoom_camera.make_current()
	print("SWITCH TO ZOOM CAMERA")
	var zoom_factor : float = get_target_zoom(map_global_rect.size)
	
	var tween = create_tween()
	tween.tween_property(zoom_camera, "zoom", Vector2(zoom_factor, zoom_factor), 2).set_ease(Tween.EASE_IN_OUT)
	tween.parallel()
	tween.tween_property(zoom_camera, "global_position", map_global_rect.get_center(), 2).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "zoom_completed"))

func zoom_completed() -> void:
	var state_play : PlayState = our_state_machine.get_play_state()
	state_play.mutate_map()
	our_state_machine.switch_state("PlayState_ZoomIn")
	
func get_target_zoom(global_size : Vector2) -> float:
	var viewport : Viewport = get_viewport()
	var viewport_size : Vector2 = viewport.get_visible_rect().size
	var zoom_factor : float = min(viewport_size.x / global_size.x, viewport_size.y / global_size.y)
	return zoom_factor
