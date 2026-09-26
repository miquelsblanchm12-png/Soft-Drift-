extends Label

var car


func _ready():
	car = get_tree().current_scene.get_node("Car")
	text = "DRIFT SCORE\n0"
	modulate.a = 0.85


func _process(delta):
	if not car:
		return

	var s = "DRIFT SCORE\n" + str(car.drift_points)
	if car.drift and abs(car.speed) > car.drift_entry_speed:
		text = s + "\n+ DRIFT x" + str(round(car.drift_combo * 10.0) / 10.0)
		modulate.a = lerp(modulate.a, 1.0, delta * 8.0)
	else:
		text = s
		modulate.a = lerp(modulate.a, 0.85, delta * 4.0)
