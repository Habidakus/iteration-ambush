extends StateMachineState

var rooms : Array[Room]

func enter_state() -> void:
	super.enter_state()
	%PlayStateMachine.switch_state("PlayState_LevelSetup")

func init_map() -> void:
	var r1 = Room.new()
	var r2 = Room.new()
	var r3 = Room.new()
	var r4 = Room.new()

	r1.north = r2
	r2.south = r1
	
	r2.west = r3
	r3.east = r2
	
	r3.south = r4
	r4.north = r3
	
	rooms.append(r1)
	rooms.append(r2)
	rooms.append(r3)
	rooms.append(r4)
	
	r1.ApplyToMaps(%TerrainMap, %ObjectMap)

func spawn_map() -> void:
	print("TODO: SPAWN ENEMIES")
