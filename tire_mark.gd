extends Node3D

var life = 5.0


func _process(_delta):
	life -= delta
	if life <= 0.0:
		queue_free()
