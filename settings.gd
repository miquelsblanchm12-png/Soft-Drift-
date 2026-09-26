extends Control


func _ready():
	if has_node("MasterSlider"):
		var master = $MasterSlider
		master.value = Global.master_volume
		master.value_changed.connect(_on_master_volume_changed)

	if has_node("MusicSlider"):
		var music = $MusicSlider
		music.value = Global.music_volume
		music.value_changed.connect(_on_music_volume_changed)

	if has_node("SfxSlider"):
		var sfx = $SfxSlider
		sfx.value = Global.sfx_volume
		sfx.value_changed.connect(_on_sfx_volume_changed)

	if has_node("BackButton"):
		$BackButton.pressed.connect(back_menu)


func _on_master_volume_changed(value):
	Global.master_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))


func _on_music_volume_changed(value):
	Global.music_volume = value
	var bus = AudioServer.get_bus_index("Music")
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))


func _on_sfx_volume_changed(value):
	Global.sfx_volume = value
	var bus = AudioServer.get_bus_index("SFX")
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))


func back_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
