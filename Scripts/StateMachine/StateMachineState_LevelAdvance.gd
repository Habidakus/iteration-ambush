extends StateMachineState

var player_card_resource = preload("res://Scene/player_mod_card.tscn")

var player_mods : Array[PlayerMod]
func enter_state() -> void:
	super.enter_state()
	%State_Play.clean_map()
	player_mods = %State_Play.pick_player_mods()
	for i in range(1, 5):
		var cl : Control = (find_child("Control" + str(i)) as Control)
		if i <= player_mods.size():
			cl.visible = true
			var pm : PlayerMod = player_mods[i-1]
			(cl.find_child("Title") as Label).text = pm.get_title()
			(cl.find_child("Description") as Label).text = pm.get_description()
			#print(pm.get_title() + " // " + pm.get_description())
		else:
			cl.visible = false
	(find_child("HBoxContainer") as HBoxContainer).force_update_transform()

func exit_state(next_state: StateMachineState) -> void:
	super.exit_state(next_state)

func select(event: InputEvent, index : int) -> void:
	var iemb : InputEventMouseButton = event as InputEventMouseButton
	if iemb != null && iemb.is_released():
		var pm : PlayerMod = player_mods[index]
		print("Selected: " + pm.get_title())
		%State_Play.apply_player_mod(pm)
		%State_Play.mutate_map()
		%State_Play.spawn_map()

func on_card1_gui_input(event: InputEvent) -> void:
	select(event, 0)
func on_card2_gui_input(event: InputEvent) -> void:
	select(event, 1)
func on_card3_gui_input(event: InputEvent) -> void:
	select(event, 2)
func on_card4_gui_input(event: InputEvent) -> void:
	select(event, 3)
