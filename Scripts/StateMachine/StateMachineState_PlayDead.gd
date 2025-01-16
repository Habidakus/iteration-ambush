extends StateMachineState


var timer : float = 3

func enter_state() -> void:
	super.enter_state()
	timer = 3.0
	%Player.stop_anim()
	(find_child("RestartButton") as CanvasItem).visible = false

func _process(delta : float) -> void:
	if timer >= 0:
		timer -= delta
		if timer < 0:
			(find_child("RestartButton") as CanvasItem).visible = true

func _on_restart_button_button_up() -> void:
	%State_Play.restart()
