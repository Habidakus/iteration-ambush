extends StaticBody2D

class_name DaggerThrower

var room : Room = null
var player : Player = null
var cooldown_max : float
var cooldown_current : float

var dagger_scene : Resource = preload("res://Scene/dagger.tscn")

func init(_room : Room, _cooldown_length : float) -> void:
	room = _room
	player = room.play_state.get_player()
	cooldown_max = _cooldown_length
	cooldown_current = cooldown_max

func fire() -> void:
	var bullet : Dagger = dagger_scene.instantiate()
	#bullet.global_position = self.global_position
	bullet.global_position = to_global(to_local(global_position)) #- Vector2(20,20)
	#print("b=" + str(bullet.global_position) + "  p=" + str(global_position))
	bullet.look_at(player.global_position)
	bullet.position -= Vector2(20,20)
	bullet.position += Vector2.RIGHT.rotated(bullet.rotation) * 32.0
	bullet.init(player)
	room.play_state.add_child(bullet)
	cooldown_current = cooldown_max

func _process(delta: float) -> void:
	look_at(player.global_position)
	
	cooldown_current -= delta
	if cooldown_current < 0:
		fire()
