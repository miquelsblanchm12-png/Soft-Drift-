extends Camera3D

var distance = 7.0
var height = 3.5
var smooth = 4.0
var car
var ready_done = false


func _ready():
	car = get_parent().get_parent()
	top_level = true
	var arm = get_parent()
	if arm is SpringArm3D:
		arm.spring_length = 0.0


func snap_behind_car():
	var t = car.get_global_transform_interpolated()
	global_position = t.origin - t.basis.z * distance + Vector3.UP * height
	look_at(t.origin + Vector3.UP, Vector3.UP)
	ready_done = true


func _process(delta):
	if not ready_done:
		snap_behind_car()

	var t = car.get_global_transform_interpolated()
	var wanted = t.origin - t.basis.z * distance + Vector3.UP * height
	global_position = global_position.lerp(wanted, 1.0 - exp(-smooth * delta))

	var target = t.origin + Vector3.UP
	if target.distance_to(global_position) > 0.05:
		look_at(target, Vector3.UP)
