extends Node3D

var wheels = 0
var total_wheels = 10
var time_left = 120.0
var game_finished = false
var wheel_label
var timer_label

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $DirectionalLight3D



func _ready():
	Global.play_game_music()
	wheel_label = find_child("WheelLabel", true)
	timer_label = find_child("TimerLabel", true)

	if wheel_label:
		wheel_label.text = "WHEELS 0/10"
	if timer_label:
		timer_label.text = "02:00"

	setup_bright_lighting()


func setup_bright_lighting():
	if world_environment and world_environment.environment:
		var env = world_environment.environment
		var sky = Sky.new()
		var sky_material = PanoramaSkyMaterial.new()
		sky_material.panorama = load("res://scenes/sky_90_2k.png")
		sky.sky_material = sky_material
		env.sky = sky
		env.background_mode = Environment.BG_SKY
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.78, 0.79, 0.8)
		env.ambient_light_energy = 0.95
		env.background_energy_multiplier = 0.85
		env.fog_enabled = false

	if sun:
		sun.light_color = Color(0.95, 0.93, 0.88)
		sun.light_energy = 1.0
		sun.shadow_enabled = false


func _process(delta):
	if game_finished:
		return

	if time_left <= 0.0:
		return

	time_left = max(time_left - delta, 0.0)
	var min = int(time_left) / 60
	var sec = int(time_left) % 60

	if timer_label:
		timer_label.text = "%02d:%02d" % [min, sec]

	if time_left <= 0.0:
		lose_game()


func add_wheel():
	if game_finished:
		return

	wheels += 1
	if wheel_label:
		wheel_label.text = "WHEELS " + str(wheels) + "/10"
	if wheels >= total_wheels:
		win_game()


func win_game():
	if game_finished:
		return
	game_finished = true

	var sound = AudioStreamPlayer.new()
	sound.stream = load("res://audio/gameplay/victory_6.mp3")
	get_tree().root.add_child(sound)
	sound.play()
	sound.finished.connect(sound.queue_free)

	var car = get_node("Car")
	Global.victory = true
	Global.final_score = car.drift_points
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/win_lose.tscn")


func lose_game():
	if game_finished:
		return
	game_finished = true

	var sound = AudioStreamPlayer.new()
	sound.stream = load("res://audio/gameplay/Fail sound effect [RIFDznK3SvY].mp3")
	get_tree().root.add_child(sound)
	sound.play()
	sound.finished.connect(sound.queue_free)

	var car = get_node("Car")
	Global.victory = false
	Global.final_score = car.drift_points
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/win_lose.tscn")
