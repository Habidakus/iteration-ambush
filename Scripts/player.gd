extends CharacterBody2D

class_name Player

const SPEED = 300.0

var save_vel : Vector2
var acc : Vector2
var our_momentum : Vector2

func _physics_process(_delta: float) -> void:
	#Input.is_action_just_pressed("ui_accept"):

	#var acc : float = SPEED * _delta
		
	# Start and stop quickly
	#var v_s : float = velocity.length_squared()
	#if v_s < 100 * 100:
		#acc = (acc + 0) / 2.0

	#velocity = save_vel
	
	var acc_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if acc_dir == Vector2.ZERO:
		var slow = (1 - _delta)
		slow = slow * slow
		velocity = our_momentum * slow
	else:
		velocity = (acc_dir * SPEED + our_momentum).normalized() * SPEED

	#var dx : float = Input.get_axis("ui_left", "ui_right")
	#if dx != 0:
		#velocity.x = move_toward(velocity.x, SPEED * dx, acc.x)
	#else:
		#velocity.x = move_toward(velocity.x, 0, acc.x)
		#
	#var dy : float = Input.get_axis("ui_up", "ui_down")
	#if dy != 0:
		#velocity.y = move_toward(velocity.y, SPEED * dy, acc.x)
	#else:
		#velocity.y = move_toward(velocity.y, 0, acc.x)

	#print(str(velocity.length()) )

	#save_vel = velocity
	#var pre_pos = self.position

	move_and_slide()
	
	our_momentum = get_position_delta() / _delta

	if velocity != Vector2.ZERO:
		up_direction = Vector2.ZERO - velocity
	
	#var collision : KinematicCollision2D = move_and_collide(velocity * _delta)
	#if collision:
	
	%State_Play.trigger_player_location_events(position)
