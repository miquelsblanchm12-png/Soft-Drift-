extends Node3D

var orb_scene = preload("res://scenes/orb.tscn")


func _ready():
	var points = get_children()
	for point in points:
		var orb = orb_scene.instantiate()
		get_parent().add_child.call_deferred(orb)
		orb.set_deferred("global_position", point.global_position)
