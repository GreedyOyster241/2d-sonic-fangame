extends CharacterBody2D

# --- Movement tuning ---
var run_speed: float = 800.0      # Max speed
var run_threshold: float = 300.0   # Speed at which Sonic can skid
var acceleration: float = 500.0    # How fast Sonic gets to max speed
var jump_speed: float = -1200.0    # More negative = higher jump

var friction: float = 1250.0       # How fast Sonic stops
var turn_acceleration: float = 1000.0

var fall_speed: float = 2400.0     # Max falling speed
var gravity: float = 4000.0        # How fast Sonic reaches fall speed

# --- Direction ---
var direction: float = 0.0         # Input direction (1 = right, -1 = left)
var last_direction: int = 1        # Last non-zero direction

# --- States ---
var is_crouching: bool = false
var is_looking_up: bool = false
var is_skidding: bool = false
var ball: bool = false
var speedtimer = 0.0
var sonicboombool = false

var spindashing: bool = false      # true while in spindash charge state
var speed_charge: float = 0.0

var current_anim: String = ""


func get_input() -> void:
	var right := Input.is_action_pressed("Right")
	var left := Input.is_action_pressed("Left")
	var down := Input.is_action_pressed("Down")
	var up := Input.is_action_pressed("Up")
	var jump_pressed := Input.is_action_just_pressed("Jump")
	var jump_held := Input.is_action_pressed("Jump")
	
	# --- Facing / last direction ---
	if right:
		$AnimatedSprite2D.flip_h = false
		last_direction = 1
	elif left:
		$AnimatedSprite2D.flip_h = true
		last_direction = -1
	
	# --- Crouch + Spindash CHARGE (Down on floor, almost stopped) ---
	if is_on_floor() and down and abs(velocity.x) < 10.0:
		is_crouching = true
		
		
		# Each press of Jump adds revs
		if jump_pressed:
			spindashing = true
			speed_charge += 500.0
			speed_charge = clamp(speed_charge, 200.0, 2500.0)
	else:
		# Only uncrouch if not spindashing anymore
		if not spindashing:
			is_crouching = false
	
	# --- Spindash RELEASE (let go of Down while spindashing) ---
	if spindashing and is_on_floor() and not down:
		var dir := last_direction
		if dir == 0:
			dir = 1
		
		velocity.x = dir * speed_charge
		ball = true              # turn into ball after release
		spindashing = false
		speed_charge = 0.0
	
	# --- Normal jump (only if not holding Down or in spindash) ---
	if is_on_floor() and jump_pressed and not down and not spindashing:
		velocity.y = jump_speed
	
	# --- Look up ---
	if up and is_on_floor() and velocity.x == 0.0 and not spindashing and not is_crouching:
		is_looking_up = true
	else:
		is_looking_up = false


func previous_direction() -> void:
	if direction != 0.0:
		last_direction = int(sign(direction))
	else:
		if velocity.x < 0.0:
			last_direction = -1
		elif velocity.x > 0.0:
			last_direction = 1


func _gravity(delta: float) -> void:
	velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)


func _physics_process(delta: float) -> void:
	
	
	_gravity(delta)
	get_input()
	
	sonicboombool = false
	direction = Input.get_axis("Left", "Right")
	previous_direction()
	
	if direction != 0 and abs(velocity.x) > 50 and not ball and not spindashing:
		speedtimer += delta
	else:
		speedtimer = 0

	
	# --- Movement / acceleration ---
	if spindashing and is_on_floor() and Input.is_action_pressed("Down"):
		# Stay in place while charging spindash
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	else:
		if direction != 0.0:
			if direction * velocity.x < 0.0:
				velocity.x = move_toward(velocity.x, direction * run_speed, turn_acceleration * delta)
			else:
				velocity.x = move_toward(velocity.x, direction * run_speed, acceleration * delta)
			
			# --- SPEED BOOST WHEN HOLDING MAX SPEED ---
			if speedtimer >= 3.0:
				run_speed = 1300   # boosted speed
				sonicboombool = true
				
			else:
				run_speed = 800    # normal speed

		else:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	
	# --- Skidding (disabled while ball/spindash) ---
	if is_on_floor() and not ball and not spindashing:
		if direction != 0.0 and velocity.x != 0.0 and direction * velocity.x < 0.0 \
		and abs(velocity.x) > run_threshold:
			is_skidding = true
		else:
			is_skidding = false
	else:
		is_skidding = false
	
	# --- Rolling (manual ball from Down + speed) ---
	if is_on_floor() and Input.is_action_pressed("Down") and abs(velocity.x) > 200.0 and not spindashing:
		ball = true
	
	if ball:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		# End roll when too slow or airborne
		if abs(velocity.x) < 50.0 or not is_on_floor():
			ball = false
	
	move_and_slide()
	animation_handler()


func animation_handler() -> void:
	var anim := ""
	var jump_held := Input.is_action_pressed("Jump")
	
	if not is_on_floor():
		anim = "jump"
	elif is_crouching and not spindashing:
		anim = "down"
	elif is_looking_up:
		anim = "look_up"
	elif is_skidding:
		anim = "skid"
	elif spindashing:
		# In spindash state:
		#  - Jump held  -> spindash_rev
		#  - Jump not held -> spindash
		if jump_held:
			anim = "spindash_rev"
		else:
			anim = "spindash"
	elif ball:
		anim = "roll"
	elif abs(velocity.x) > 800.0:
		anim = "max_run"
	elif abs(velocity.x) > 500.0:
		anim = "run"
	elif abs(velocity.x) > 200.0:
		anim = "jog"
	elif velocity.x != 0.0 and is_on_floor():
		anim = "walk"
	else:
		anim = "default"
	
	if anim != current_anim:
		current_anim = anim
		$AnimatedSprite2D.play(anim)
		sound_handler(anim)


func sound_handler(anim: String) -> void:
	var runtrack := false
	var steptrack := false
	
	
	if sonicboombool == true:
		$sonicboom.play()
	
	match anim:
		"jump":
			$jump.play()
			await get_tree().create_timer(0.24).timeout
			$spin.play()
		
		"skid":
			$skid.play()
		
		"walk":
			steptrack = true
			if not runtrack:
				$wind.stop()
		
		"jog":
			steptrack = true
			if not runtrack:
				$wind.stop()
		
		"run":
			$wind.play()
			runtrack = true
			steptrack = true
		
		"max_run":
			runtrack = true
			steptrack = true
			
		"spindash_rev":
			$roll.play()
			
		"roll":
			$roll.play()
			
		"default":
			if not steptrack:
				$footstep.stop()
		
		_:
			pass
