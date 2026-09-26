extends Control

var victory = false
var score = 0

@onready var title = $Title
@onready var score_label = $Score
@onready var retry_button = $RetryButton
@onready var menu_button = $MenuButton


func _ready():
	retry_button.pressed.connect(retry)
	menu_button.pressed.connect(menu)

	if Global.victory:
		title.text = "VICTORY"
	else:
		title.text = "DEFEAT"

	score_label.text = "DRIFT SCORE: " + str(Global.final_score)


func retry():
	Global.victory = false
	Global.final_score = 0
	get_tree().change_scene_to_file("res://scenes/loading.tscn")


func menu():
	Global.victory = false
	Global.final_score = 0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
