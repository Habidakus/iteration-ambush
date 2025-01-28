extends StateMachineState

func enter_state() -> void:
	super.enter_state()
	
	var zoom_camera : Camera2D = %PlayStateMachine/ZoomCamera as Camera2D
	var player_camera : Camera2D = %Player.get_camera()
	var state_play : PlayState = our_state_machine.get_play_state()
	state_play.move_player_to_first_room()
	
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(zoom_camera, "zoom", player_camera.zoom, 2).set_ease(Tween.EASE_IN)
	tween.parallel()
	tween.tween_property(zoom_camera, "global_position", player_camera.global_position, 2).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "zoom_completed"))

func zoom_completed() -> void:
	var state_play : PlayState = our_state_machine.get_play_state()
	state_play.spawn_map()

	var viewport : Viewport = get_viewport()  #viewport_set_snap_2d_vertices_to_pixel()
	viewport.snap_2d_vertices_to_pixel  = false
