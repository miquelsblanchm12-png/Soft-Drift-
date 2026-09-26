extends CharacterBody3D

var speed = 0.0
var max_speed = 20.0
var reverse_speed = 6.0
var acceleration = 8.5
var braking = 14.0
var friction = 4.5
var drift_acceleration = 2.2
var gravity = 25.0

var steering = 1.5
var steer_input = 0.0
var steering_response = 9.0
var normal_grip = 10.0
var handbrake_grip = 1.5
var drift_force = 11.5
var drift_turn = 1.18
var drift_model_turn = 0.42
var drift_speed_loss = 0.35
var drift_entry_speed = 3.0
var drift_exit_speed = 1.5

var drift = false
var drift_amount = 0.0
var drift_grace_time = 0.0
var drift_grace_limit = 0.28
var drift_points = 0
var drift_combo = 1.0
var drift_time = 0.0

var mark_distance = 0.5
var last_mark_left = Vector3.ZERO
var last_mark_right = Vector3.ZERO
var tire_mark_scene = preload("res://scenes/tire_mark.tscn")

@onready var car1 = $Car1
@onready var car2 = $Car2
@onready var mark_left = $MarkLeft
@onready var mark_right = $MarkRight
@onready var drift_sound = get_node("../DriftSound")

var engine_sound
var car_model
var car_model_start_rotation = Vector3.ZERO
var visual_target_yaw = 0.0


func _ready():
	floor_snap_length = 0.2
	floor_max_angle = deg_to_rad(50.0)
	floor_stop_on_slope = false

	engine_sound = AudioStreamPlayer3D.new()
	engine_sound.stream = load("res://audio/car/Driving Car Sound Effect (Inside).wav")
	engine_sound.bus = "Master"
	engine_sound.volume_db = -18.0
	add_child(engine_sound)
	engine_sound.finished.connect(_loop_engine_sound)
	engine_sound.play()

	if Global.selected_car == 1:
		car1.visible = true
		car2.visible = false
		car_model = car1
	else:
		car1.visible = false
		car2.visible = true
		car_model = car2

	car_model_start_rotation = car_model.rotation
	visual_target_yaw = car_model_start_rotation.y


func _loop_engine_sound():
	if engine_sound and is_inside_tree():
		engine_sound.play()


func _physics_process(delta):
	var gas = Input.get_action_strength("move_forward")
	var reverse = Input.get_action_strength("move_back")
	var left = Input.get_action_strength("move_left")
	var right = Input.get_action_strength("move_right")
	var steer_target = right - left

	steer_input = move_toward(steer_input, steer_target, steering_response * delta)
	var steer = steer_input
	var pressing_drift = Input.is_action_pressed("drift")
	var can_drift = abs(speed) > drift_entry_speed and abs(steer) > 0.08

	if pressing_drift and can_drift:
		drift_grace_time = drift_grace_limit
	else:
		drift_grace_time -= delta

	if drift_grace_time > 0.0 and abs(speed) > drift_exit_speed:
		drift = true
	else:
		drift = false
		drift_grace_time = max(drift_grace_time, 0.0)

	if drift:
		if not drift_sound.playing:
			drift_sound.play()
	else:
		if drift_sound.playing:
			drift_sound.stop()

	if gas > 0.0:
		if drift:
			speed += drift_acceleration * delta
		else:
			speed += acceleration * delta
	elif reverse > 0.0:
		if speed > 0.0:
			speed = move_toward(speed, 0.0, braking * delta)
		else:
			speed -= acceleration * 0.65 * delta
	else:
		speed = move_toward(speed, 0.0, friction * delta)

	if drift:
		speed = move_toward(speed, 0.0, drift_speed_loss * delta)

	speed = clamp(speed, -reverse_speed, max_speed)

	if drift:
		drift_amount = move_toward(drift_amount, 1.0, 5.5 * delta)
	else:
		drift_amount = move_toward(drift_amount, 0.0, 4.0 * delta)

	var forward = -transform.basis.z
	var right_direction = transform.basis.x
	var forward_speed = velocity.dot(forward)
	var side_speed = velocity.dot(right_direction)

	if abs(speed) > 0.5:
		var turn = steering * steer
		if speed < 0.0:
			turn *= -1.0
		if drift:
			turn *= drift_turn
		rotation.y -= turn * delta

	forward = -transform.basis.z
	right_direction = transform.basis.x
	forward_speed = lerp(forward_speed, speed, 4.0 * delta)

	var grip = lerp(normal_grip, handbrake_grip, drift_amount)
	side_speed = lerp(side_speed, 0.0, grip * delta)

	if drift and abs(speed) > drift_entry_speed:
		side_speed += sign(steer) * drift_force * drift_amount * delta
		side_speed = clamp(side_speed, -max_speed * 0.75, max_speed * 0.75)

	var new_velocity = forward * forward_speed + right_direction * side_speed
	velocity.x = new_velocity.x
	velocity.z = new_velocity.z

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta

	move_and_slide()

	var roll_goal = car_model_start_rotation.z
	if drift and abs(steer) > 0.05:
		visual_target_yaw = car_model_start_rotation.y - steer * drift_model_turn
		roll_goal -= steer * drift_amount * 0.06

	car_model.rotation.y = lerp_angle(car_model.rotation.y, visual_target_yaw, 12.0 * delta)
	car_model.rotation.z = lerp(car_model.rotation.z, roll_goal, 8.0 * delta)

	mark_left.position.x = -0.7
	mark_right.position.x = 0.7
	mark_left.rotation.y = car_model.rotation.y
	mark_right.rotation.y = car_model.rotation.y

	if drift and abs(speed) > 3.0 and abs(steer) > 0.05:
		if last_mark_left.distance_to(mark_left.global_position) > mark_distance:
			var mark1 = tire_mark_scene.instantiate()
			get_parent().add_child(mark1)
			mark1.global_position = mark_left.global_position
			mark1.global_rotation.y = rotation.y + car_model.rotation.y
			last_mark_left = mark_left.global_position

		if last_mark_right.distance_to(mark_right.global_position) > mark_distance:
			var mark2 = tire_mark_scene.instantiate()
			get_parent().add_child(mark2)
			mark2.global_position = mark_right.global_position
			mark2.global_rotation.y = rotation.y + car_model.rotation.y
			last_mark_right = mark_right.global_position

	if drift and abs(speed) > drift_entry_speed and abs(steer) > 0.05:
		drift_time += delta
		var points = int(abs(side_speed) * 10.0 * delta * drift_combo)
		drift_points += points
		drift_combo = min(drift_combo + delta * 0.22, 4.0)
	else:
		drift_time = max(drift_time - delta * 0.5, 0.0)
		drift_combo = move_toward(drift_combo, 1.0, delta * 0.9)

	if engine_sound:
		var ratio = clamp(abs(speed) / max_speed, 0.0, 1.0)
		engine_sound.pitch_scale = 0.8 + ratio * 0.5
		engine_sound.volume_db = lerp(-18.0, -4.0, ratio)
