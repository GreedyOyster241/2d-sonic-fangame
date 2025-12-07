extends CharacterBody2D

<<<<<<< HEAD


var run_speed = 800
var run_threshold = 300
var acceleration = 500
var jump_speed = -1200

var direction = 0
var last_direction = 1
var friction = 1000
var turn_acceleration = 1000

var is_crouching = false
var is_looking_up = false
var is_skidding = false
var ball = false

var fall_speed = 2400
var gravity = 4000 




func get_input():
=======
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
>>>>>>> 6fb7933967cc3a422b3c86f8e1ee8221aa21afd2
	var right = Input.is_action_pressed('Right')
	var left = Input.is_action_pressed('Left')
	var down = Input.is_action_pressed('Down')
	var up = Input.is_action_pressed('Up')
	var jump = Input.is_action_just_pressed('Jump')
	
<<<<<<< HEAD
	
	if is_on_floor() and jump and velocity.y < 0:
		velocity.y = (velocity.y / 2) + 10
	elif is_on_floor() and jump:
		velocity.y = jump_speed
	if right:
		$AnimatedSprite2D.flip_h = false
	if left:
=======
	if is_on_floor() and jump:
		velocity.y = jump_speed
	if right:
		velocity.x += run_speed
		$AnimatedSprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
>>>>>>> 6fb7933967cc3a422b3c86f8e1ee8221aa21afd2
		$AnimatedSprite2D.flip_h = true
	if down and is_on_floor() and velocity.x == 0:
		is_crouching = true
	else:
		is_crouching = false
	if up and is_on_floor() and velocity.x == 0:
		is_looking_up = true
	else:
		is_looking_up = false

<<<<<<< HEAD

=======
>>>>>>> 6fb7933967cc3a422b3c86f8e1ee8221aa21afd2
func previous_direction():
	if direction:
		last_direction = direction
	else:
		if velocity.x < 0:
			last_direction = -1
		elif velocity.x > 0:
			last_direction = 1

<<<<<<< HEAD
func _gravity(delta: float) -> void:	
=======
func _gravity(delta: float) -> void:
>>>>>>> 6fb7933967cc3a422b3c86f8e1ee8221aa21afd2
	velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)

func _physics_process(delta: float) -> void:
	_gravity(delta)
	get_input()
<<<<<<< HEAD
	direction = Input.get_axis("Left", "Right")
	previous_direction()
	
	#Movement
=======
	direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	previous_direction()
>>>>>>> 6fb7933967cc3a422b3c86f8e1ee8221aa21afd2
	if direction:
		if direction * velocity.x < 0:
			velocity.x = move_toward(velocity.x, direction * run_speed, turn_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * run_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
<<<<<<< HEAD
		
	#Skidding
	if is_on_floor():
		if direction != 0 and velocity.x != 0 and direction * velocity.x < 0 and abs(velocity.x) > run_threshold:
			is_skidding = true
		else:
			is_skidding = false
	
	#ball
	if is_on_floor() and Input.is_action_pressed('Down') and abs(velocity.x) > 200:
		ball = true
		print("Ball!!")
	else: 
		ball = false
	
	if ball:
			velocity.x = move_toward(velocity.x, 0, friction * delta)


=======
>>>>>>> 6fb7933967cc3a422b3c86f8e1ee8221aa21afd2
	move_and_slide()
	animation_handler()

func animation_handler():
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
	elif is_crouching:
		$AnimatedSprite2D.play("down")
	elif is_looking_up:
		$AnimatedSprite2D.play("look_up")
<<<<<<< HEAD
	elif is_skidding:
		$AnimatedSprite2D.play("skid")
	elif ball:
		$AnimatedSprite2D.play("roll")
=======
>>>>>>> 6fb7933967cc3a422b3c86f8e1ee8221aa21afd2
	elif abs(velocity.x) > 500:
		$AnimatedSprite2D.play("run")
	elif abs(velocity.x) > 200:
		$AnimatedSprite2D.play("jog")
	elif velocity.x != 0 and is_on_floor():
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("default")
<<<<<<< HEAD

#TODO: FIX NOT PLAYING
func sound_handler():
	if Input.is_action_just_pressed('Jump'):
		$jump.play()
		await get_tree().create_timer(0.5).timeout
		$spin.play()
	#if is_skidding:
		#$skid.play()
=======
>>>>>>> 6fb7933967cc3a422b3c86f8e1ee8221aa21afd2
