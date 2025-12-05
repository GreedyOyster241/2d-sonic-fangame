extends CharacterBody2D

var run_speed = 800
var acceleration = 180
var jump_speed = -1100

var direction = 0
var last_direction = 1
var friction = 2500000
var turn_acceleration = 600

var is_crouching = false
var is_looking_up = false

var fall_speed = 1200
var gravity = 2500


func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('Right')
	var left = Input.is_action_pressed('Left')
	var down = Input.is_action_pressed('Down')
	var up = Input.is_action_pressed('Up')
	var jump = Input.is_action_just_pressed('Jump')
	
	if is_on_floor() and jump:
		velocity.y = jump_speed
	if right:
		velocity.x += run_speed
		$AnimatedSprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$AnimatedSprite2D.flip_h = true
	if down and is_on_floor() and velocity.x == 0:
		is_crouching = true
	else:
		is_crouching = false
	if up and is_on_floor() and velocity.x == 0:
		is_looking_up = true
	else:
		is_looking_up = false

func previous_direction():
	if direction:
		last_direction = direction
	else:
		if velocity.x < 0:
			last_direction = -1
		elif velocity.x > 0:
			last_direction = 1

func _gravity(delta: float) -> void:
	velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)

func _physics_process(delta: float) -> void:
	_gravity(delta)
	get_input()
	direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	previous_direction()
	if direction:
		if direction * velocity.x < 0:
			velocity.x = move_toward(velocity.x, direction * run_speed, turn_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * run_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	move_and_slide()
	animation_handler()

func animation_handler():
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
	elif is_crouching:
		$AnimatedSprite2D.play("down")
	elif is_looking_up:
		$AnimatedSprite2D.play("look_up")
	elif abs(velocity.x) > 500:
		$AnimatedSprite2D.play("run")
	elif abs(velocity.x) > 200:
		$AnimatedSprite2D.play("jog")
	elif velocity.x != 0 and is_on_floor():
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("default")
