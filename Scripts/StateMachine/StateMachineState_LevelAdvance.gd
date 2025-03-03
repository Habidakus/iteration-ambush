extends StateMachineState

var player_card_resource = preload("res://Scene/player_mod_card.tscn")
var player_mods : Array[PlayerMod]

func enter_state() -> void:
	super.enter_state()
	var state_play : PlayState = our_state_machine.get_play_state()
	state_play.clean_map()
	%Player.set_ui_visibility(true)
	state_play.update_waves_remaining(Callable(self, "update_waves_remaining"))
	(find_child("CoinTotal") as CanvasItem).visible = true
	(find_child("WavesToGo") as CanvasItem).visible = true
	(find_child("ModsAvailable") as CanvasItem).visible = false
	var update_coin_callable : Callable = Callable(self, "update_coin")
	var has_enough : Callable = Callable(self, "display_mods")
	var is_short : Callable = Callable(self, "transition_to_next_state")
	state_play.drain_coins(update_coin_callable, has_enough, is_short)

func exit_state(next_state: StateMachineState) -> void:
	%Player.set_ui_visibility(false)
	super.exit_state(next_state)

func update_coin(new_coin_value : int) -> void:
	var total_coins_label : Label = find_child("TotalCoinsLabel") as Label
	total_coins_label.text = str(new_coin_value)

func update_waves_remaining(new_waves_remaining : int) -> void:
	var waves_remaining_label : Label = find_child("WavesRemainingLabel") as Label
	waves_remaining_label.text = str(new_waves_remaining)

func display_mods() -> void:
	(find_child("CoinTotal") as CanvasItem).visible = false
	(find_child("WavesToGo") as CanvasItem).visible = false
	(find_child("ModsAvailable") as CanvasItem).visible = true
	player_mods = our_state_machine.get_play_state().pick_player_mods()
	for i in range(1, 5):
		var cl : Control = (find_child("Control" + str(i)) as Control)
		if i <= player_mods.size():
			cl.visible = true
			var pm : PlayerMod = player_mods[i-1]
			(cl.find_child("Title") as Label).text = pm.get_title()
			(cl.find_child("Description") as Label).text = pm.get_description()
		else:
			cl.visible = false
	(find_child("HBoxContainer") as HBoxContainer).force_update_transform()

func transition_to_next_state() -> void:
	our_state_machine.switch_state("PlayState_ZoomOut")

func select(event: InputEvent, index : int) -> void:
	var iemb : InputEventMouseButton = event as InputEventMouseButton
	if iemb != null && iemb.is_released():
		var pm : PlayerMod = player_mods[index]
		our_state_machine.get_play_state().apply_player_mod(pm)
		transition_to_next_state()

func on_card1_gui_input(event: InputEvent) -> void:
	select(event, 0)
func on_card2_gui_input(event: InputEvent) -> void:
	select(event, 1)
func on_card3_gui_input(event: InputEvent) -> void:
	select(event, 2)
func on_card4_gui_input(event: InputEvent) -> void:
	select(event, 3)
