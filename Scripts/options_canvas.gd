extends CanvasLayer

var inhibit_setting : bool = false
var state_play_process_mode : ProcessMode
 
func toggle_presence() -> void:
	self.visible = !self.visible
	
	if self.visible:
		inhibit_setting = true

		state_play_process_mode = %State_Play.process_mode
		%State_Play.process_mode = ProcessMode.PROCESS_MODE_DISABLED
	
		prime_slider(AudioServer.get_bus_index("Master"), find_child("MasterSlider") as HSlider)
		prime_slider(AudioServer.get_bus_index("Music"), find_child("MusicSlider") as HSlider)
		prime_slider(AudioServer.get_bus_index("FX"), find_child("FXSlider") as HSlider)
		prime_slider(AudioServer.get_bus_index("UI"), find_child("UISlider") as HSlider)

		inhibit_setting = false
	else:
		%State_Play.process_mode = state_play_process_mode

func prime_slider(bus_index : int, slider : HSlider) -> void:
	if AudioServer.is_bus_mute(bus_index):
		slider.value = 0
	else:
		var db : float = AudioServer.get_bus_volume_db(bus_index)
		slider.value = max(1, 100 + db)

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_presence()

func _on_show_blood_toggled(toggled_on: bool) -> void:
	%Player.set_show_blood(toggled_on)

func adjust_bus(bus_index : int, volume : float) -> void:
	if volume == 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, volume - 100)

func _on_master_slider_value_changed(value: float) -> void:
	if inhibit_setting:
		return
	var bus_index : int = AudioServer.get_bus_index("Master")
	adjust_bus(bus_index, value)

func _on_music_slider_value_changed(value: float) -> void:
	if inhibit_setting:
		return
	var bus_index : int = AudioServer.get_bus_index("Music")
	adjust_bus(bus_index, value)
	
func _on_fx_slider_value_changed(value: float) -> void:
	if inhibit_setting:
		return
	var bus_index : int = AudioServer.get_bus_index("FX")
	adjust_bus(bus_index, value)
	
func _on_ui_slider_value_changed(value: float) -> void:
	if inhibit_setting:
		return
	var bus_index : int = AudioServer.get_bus_index("UI")
	adjust_bus(bus_index, value)
