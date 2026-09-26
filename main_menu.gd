extends Control


func _ready():
	Global.play_menu_music()
	$PlayButton.pressed.connect(play_game)
	$CarsButton.pressed.connect(open_cars)
	$SettingsButton.pressed.connect(open_settings)
	$QuitButton.pressed.connect(quit_game)


func play_click_sound():
	var sound = AudioStreamPlayer.new()
	sound.stream = load("res://audio/menu/mouse-click-sound.mp3")
	add_child(sound)
	sound.play()
	sound.finished.connect(sound.queue_free)


func play_game():
	play_click_sound()
	get_tree().change_scene_to_file("res://scenes/loading.tscn")


func open_cars():
	play_click_sound()
	get_tree().change_scene_to_file("res://scenes/car_select.tscn")


func open_settings():
	play_click_sound()
	print("SETTINGS")


func quit_game():
	play_click_sound()
	get_tree().quit()
