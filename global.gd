extends Node

var selected_car = 1
var victory = false
var final_score = 0
var master_volume = 1.0
var music_volume = 0.8
var sfx_volume = 1.0
var menu_music
var menu_music_volume = -10.0
var game_music_volume = -15.0


func _ready():
	menu_music = AudioStreamPlayer.new()
	menu_music.stream = load("res://audio/menu/dusty-menu-loop [usesuno.com].ogg")
	menu_music.volume_db = menu_music_volume
	add_child(menu_music)
	menu_music.finished.connect(play_menu_music)
	play_menu_music()


func play_menu_music():
	if menu_music:
		menu_music.volume_db = menu_music_volume
		if not menu_music.playing:
			menu_music.play()


func play_game_music():
	if menu_music:
		menu_music.volume_db = game_music_volume
		if not menu_music.playing:
			menu_music.play()


func stop_menu_music():
	if menu_music and menu_music.playing:
		menu_music.stop()
