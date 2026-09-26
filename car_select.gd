extends Control

var car_number = 1

@onready var car1 = $SubViewportContainer/SubViewport/CarPreview/Car1
@onready var car2 = $SubViewportContainer/SubViewport/CarPreview/Car2


func _ready():
	Global.play_menu_music()
	$LeftButton.pressed.connect(previous_car)
	$RightButton.pressed.connect(next_car)
	$BackButton.pressed.connect(back_menu)

	for b in [$LeftButton, $RightButton, $BackButton]:
		b.pressed.connect(play_click_sound)

	update_car()


func play_click_sound():
	var sound = AudioStreamPlayer.new()
	sound.stream = load("res://audio/menu/mouse-click-sound.mp3")
	add_child(sound)
	sound.play()
	sound.finished.connect(sound.queue_free)


func previous_car():
	car_number -= 1
	if car_number < 1:
		car_number = 2
	update_car()


func next_car():
	car_number += 1
	if car_number > 2:
		car_number = 1
	update_car()


func update_car():
	car1.visible = false
	car2.visible = false
	if car_number == 1:
		car1.visible = true
	if car_number == 2:
		car2.visible = true
	$CarName.text = "CAR " + str(car_number)
	Global.selected_car = car_number


func back_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
