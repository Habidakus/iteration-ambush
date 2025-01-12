extends CharacterBody2D


const SPEED = 300.0

func _physics_process(_delta: float) -> void:
	#Input.is_action_just_pressed("ui_accept"):

	var dx : float = Input.get_axis("ui_left", "ui_right")
	if dx != 0:
		velocity.x = dx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var dy : float = Input.get_axis("ui_up", "ui_down")
	if dy != 0:
		velocity.y = dy * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	#var collision : KinematicCollision2D = move_and_collide(velocity * _delta)
	#if collision:
	
	%State_Play.trigger_player_location_events(position)
