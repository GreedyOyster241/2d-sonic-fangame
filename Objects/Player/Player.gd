extends CharacterBody2D

# --- Movement tuning ---
var run_speed: float = 800.0      # Max speed
var run_threshold: float = 300.0   # Speed at which Sonic can skid
var acceleration: float = 500.0    # How fast Sonic gets to max speed
var jump_speed: float = -700.0    # More negative = higher jump

var friction: float = 1250.0       # How fast Sonic stops
var turn_acceleration: float = 1000.0

var fall_speed: float = 2400.0     # Max falling speed
const NORMAL_GRAVITY := 1500.0
const STOMP_GRAVITY := 5000.0
const STOMP_SPEED := 700.0
var gravity: float = 1500.0        # How fast Sonic reaches fall speed

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
var is_stomping: bool = false


var spindashing: bool = false      # true while in spindash charge state
var speed_charge: float = 0.0

var current_anim: String = ""

func hit_stop(timeScale, duration):
	Engine.time_scale = timeScale
	var timer = get_tree().create_timer(timeScale * duration)
	await timer.timeout
	Engine.time_scale = 1


func badnik_bounce() -> void:
	print("badnikBounce is Called")
	velocity.y = -jump_speed
	

func get_input() -> void:
	var right := Input.is_action_pressed("Right")
	var left := Input.is_action_pressed("Left")
	var down := Input.is_action_pressed("Down")
	var up := Input.is_action_pressed("Up")
	var jump_pressed := Input.is_action_just_pressed("Jump")
	
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
		var facing = 0
		if $AnimatedSprite2D.flip_h == false:
			facing = 1
		else:
			facing = -1
		
		velocity.x = facing * speed_charge
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

func camera_handler(delta: float) -> void:
	var max_offset := 200.0
	var target_offset := 0.0

	#Use velocity, not input, to decide camera lead
	if abs(velocity.x) > 500.0:
		target_offset = clamp(velocity.x / 5.0, -max_offset, max_offset)
	else:
		target_offset = 0.0

	var weight = clamp(delta * 8.0, 0.0, 1.0)
	$Camera2D.offset.x = lerpf($Camera2D.offset.x, target_offset, weight)
	
	if is_looking_up == true:
		$Camera2D.offset.y = lerpf($Camera2D.offset.y, -150, weight)
	else:
		$Camera2D.offset.y = lerpf($Camera2D.offset.y, 0, weight)
	if is_crouching == true:
		$Camera2D.offset.y = lerpf($Camera2D.offset.y, 150, weight)
	elif spindashing == true or is_crouching == false:
		$Camera2D.offset.y = lerpf($Camera2D.offset.y, 0, weight)

func _physics_process(delta: float) -> void:
	
	#if Sonics Hurtbox collides with enemy's hurtbox
	#call
	
	if $".".position.y > 1000:
		$".".position.y = 0
		$".".position.x = 0
		
		
	_gravity(delta)
	get_input()
	
	camera_handler(delta)
	
	# --- Variable jump height ---
	if not Input.is_action_pressed("Jump") and velocity.y < 0:
		velocity.y *= 0.3    # higher = floatier, lower = sharper

	
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
		#$Camera2D.offset.y = lerpf($Camera2D.offset.y, -11.42, 2)
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
			
	
	

	# --- STOMP LOGIC ---
	if not is_on_floor() and not is_stomping and Input.is_action_just_pressed("Stomp or Bounce"):
		is_stomping = true
		ball = false  
		velocity.y = STOMP_SPEED  

# Stop stomp when you land
	if is_on_floor() and is_stomping:
		is_stomping = false

# Gravity depends on stomp state
	if is_stomping:
		gravity = STOMP_GRAVITY
	else:
		gravity = NORMAL_GRAVITY

		
	
	move_and_slide()

	animation_handler()


func animation_handler() -> void:
	var anim := ""
	var jump_held := Input.is_action_pressed("Jump")
	
	if is_stomping and not is_on_floor():
		anim = "stomp"
	elif not is_stomping and not is_on_floor():
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
	$Shockwave.emitting = false
	
	
	if sonicboombool == true:
		hit_stop(0.05, 0.6)
		$sonicboom.play()
		$Shockwave.emitting = true
	
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
				$"Camera2D".offset.x = 0
		
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
			$Trail2D.is_emitting = true
			
		"spindash_rev":
			$roll.play()
			
		"roll":
			$roll.play()
			
		"default":
			if not steptrack:
				$footstep.stop()
			$Trail2D.is_emitting = false
		
		_:
			pass
