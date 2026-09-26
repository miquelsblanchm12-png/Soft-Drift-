extends Control

var scene_path = "res://main.tscn"
var progress = []
var loading = false

@onready var progress_bar = $ProgressBar
@onready var loading_text = $LoadingText


func _ready():
	progress_bar.value = 0
	loading_text.text = "LOADING..."
	ResourceLoader.load_threaded_request(scene_path)
	loading = true


func _process(_delta):
	if not loading:
		return

	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		if progress.size() > 0:
			progress_bar.value = progress[0] * 100.0
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		progress_bar.value = 100
		loading_text.text = "READY"
		loading = false
		var scene = ResourceLoader.load_threaded_get(scene_path)
		get_tree().change_scene_to_packed(scene)
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		loading = false
		loading_text.text = "ERROR"
