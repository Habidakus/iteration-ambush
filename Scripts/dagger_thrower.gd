extends StaticBody2D

class_name DaggerThrower

var room : Room = null
var player : Player = null
var cooldown_max : float
var cooldown_current : float
var audio_player : AudioStreamPlayer

var max_dagger_distance : float = 64 * 15 / 2.25
var dagger_speed : float = 300
var dagger_damage : float = 20

var dagger_scene : Resource = preload("res://Scene/dagger.tscn")

func init(_room : Room, _cooldown_length : float, dagger_thrower_damage : float, dagger_thrower_distance : float, dagger_thrower_speed : float) -> void:
	room = _room
	player = room.play_state.get_player()
	dagger_damage = dagger_thrower_damage
	max_dagger_distance = dagger_thrower_distance
	dagger_speed = dagger_thrower_speed
	cooldown_max = _cooldown_length
	cooldown_current = cooldown_max
	audio_player = find_child("AudioStreamPlayer") as AudioStreamPlayer

func fire() -> void:
	var bullet : Dagger = dagger_scene.instantiate()
	#bullet.global_position = self.global_position
	bullet.global_position = to_global(to_local(global_position)) #- Vector2(20,20)
	#print("b=" + str(bullet.global_position) + "  p=" + str(global_position))
	bullet.look_at(player.global_position)
	bullet.position -= Vector2(20,20)
	bullet.position += Vector2.RIGHT.rotated(bullet.rotation) * 32.0
	bullet.init(player, self)
	audio_player.play()
	room.play_state.add_child(bullet)
	cooldown_current = cooldown_max

func _process(delta: float) -> void:
	look_at(player.global_position)
	
	cooldown_current -= delta
	if cooldown_current < 0:
		if (player.global_position - global_position).length_squared() < (max_dagger_distance * max_dagger_distance * 1.25):
			fire()
