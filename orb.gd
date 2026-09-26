extends Area3D

var rotation_speed = 1.5


func _ready():
	body_entered.connect(_on_body_entered)


func _process(delta):
	rotation.y += rotation_speed * delta


func _on_body_entered(body):
	if body.name != "Car":
		return

	var sound = AudioStreamPlayer.new()
	sound.stream = load("res://audio/gameplay/coin_2.mp3")
	get_tree().current_scene.add_child(sound)
	sound.play()
	sound.finished.connect(sound.queue_free)
	get_tree().current_scene.add_wheel()
	queue_free()
