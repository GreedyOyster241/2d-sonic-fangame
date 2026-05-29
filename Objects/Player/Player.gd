extends CharacterBody2D

# ─────────────────────────────────────────────
# MOVEMENT TUNING
# ─────────────────────────────────────────────
var run_speed: float = 800.0          # Max horizontal speed
var run_threshold: float = 500.0      # Speed at which Sonic can skid
var acceleration: float = 500.0       # How fast Sonic reaches max speed
var jump_speed: float = -700.0        # More negative = higher jump
var friction: float = 1750.0          # How fast Sonic stops
var turn_acceleration: float = 1000.0

# ─────────────────────────────────────────────
# GRAVITY / FALLING
# ─────────────────────────────────────────────
var fall_speed: float = 2400.0
const NORMAL_GRAVITY := 1500.0
const STOMP_GRAVITY  := 5000.0
const STOMP_SPEED    := 700.0
var gravity: float = 1500.0

# ─────────────────────────────────────────────
# DIRECTION
# ─────────────────────────────────────────────
var direction: float = 0.0       # Current input direction (1 = right, -1 = left)
var last_direction: int = 1      # Last non-zero direction

# ─────────────────────────────────────────────
# STATES
# ─────────────────────────────────────────────
var is_crouching: bool = false
var is_looking_up: bool = false
var is_skidding: bool = false
var is_stomping: bool = false
var ball: bool = false
var spindashing: bool = false
var speed_charge: float = 0.0

var charging_peelout: bool = false
var peelout: bool = false

# ─────────────────────────────────────────────
# SONIC BOOM
# ─────────────────────────────────────────────
var speedtimer: float = 0.0
var sonicboombool: bool = false      # True only on the frame the boom fires
var sonicboom_sustain: bool = false  # Locks the boom so it doesn't re-trigger

# ─────────────────────────────────────────────
# MISC
# ─────────────────────────────────────────────
var current_anim: String = ""
var tween: Tween

var looktimer = 0

signal ring_loss


# ─────────────────────────────────────────────
# UTILITY
# ─────────────────────────────────────────────

func hit_stop(timeScale: float, duration: float) -> void:
	Engine.time_scale = timeScale
	await get_tree().create_timer(timeScale * duration).timeout
	Engine.time_scale = 1.0


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


# ─────────────────────────────────────────────
# INPUT
# ─────────────────────────────────────────────

func get_input() -> void:
	var right        := Input.is_action_pressed("Right")
	var left         := Input.is_action_pressed("Left")
	var down         := Input.is_action_pressed("Down")
	var up           := Input.is_action_pressed("Up")
	var jump_pressed := Input.is_action_just_pressed("Jump")
	var jump_held := Input.is_action_pressed("Jump")

	# Facing direction
	if right:
		$AnimatedSprite2D.flip_h = false
		last_direction = 1
	elif left:
		$AnimatedSprite2D.flip_h = true
		last_direction = -1

	# Up + Peelout Charge
	if is_on_floor() and up and abs(velocity.x) < 10.0:
		is_looking_up = true
		if jump_held:
			peelout = true
			is_looking_up = false
			speed_charge = clamp(speed_charge + 30.0, 200.0, 2000.0)
	else:
		if not peelout:
			is_looking_up = false
			
	
	if peelout and is_on_floor() and not up:
		if speed_charge >= 800:
			$peeloutrelease.play()
		var facing := -1 if $AnimatedSprite2D.flip_h else 1
		velocity.x   = facing * speed_charge
		
		#if activates at certain speed, activate sonic boom
		#TODO: ONLY WORKS WHEN ALREADY MOVING
		if speed_charge >= 2000:
			sonicboombool = true
			speedtimer = 4.0
		else:
			speedtimer = 0
			
		peelout  = false
		speed_charge = 0.0
	
	
	# Crouch + spindash charge
	if is_on_floor() and down and abs(velocity.x) < 10.0:
		is_crouching = true
		if jump_pressed:
			spindashing  = true
			speed_charge = clamp(speed_charge + 500.0, 200.0, 2000.0)
	else:
		if not spindashing:
			is_crouching = false

	# Spindash release
	if spindashing and is_on_floor() and not down:
		var facing := -1 if $AnimatedSprite2D.flip_h else 1
		velocity.x   = facing * speed_charge
		ball         = true
		spindashing  = false
		speed_charge = 0.0

	# Normal jump
	if is_on_floor() and jump_pressed and not down and not spindashing and not up and not peelout:
		velocity.y = jump_speed
		
		# if jump is held during the jump
		# speed charge, play peelout sound
		# if the player lands on the ground after the jump being held
		# release drop dash, turn player into ball
		# drop dash
		if jump_held:
			print("Charging drop dash...") 
			#print(speed_charge)
			#speed_charge = clamp(speed_charge + 300.0, 200.0, 2000.0)
			#$peelout.play()
		#if is_on_floor() and jump_held:
			#print("Release!")
			#$roll.play()
			#var facing := -1 if $AnimatedSprite2D.flip_h else 1
			#velocity.x   = facing * speed_charge
			#ball         = true
			#speed_charge = 0.0

	# Look up



# ─────────────────────────────────────────────
# CAMERA
# ─────────────────────────────────────────────

func camera_handler(delta: float) -> void:
	var max_offset    := 200.0
	var target_offset_x := 0.0
	var weight: float = clamp(delta * 8.0, 0.0, 1.0)
	
	

	if abs(velocity.x) > 500.0:
		target_offset_x = clamp(velocity.x / 5.0, -max_offset, max_offset)
		$Camera2D.offset.x = lerpf($Camera2D.offset.x, target_offset_x, weight)

	# Vertical camera offset
	#TODO: even if you lightly tap up or down, timer still runs; needs a timer that 
	
	if velocity.x == 0 and velocity.y == 25 and is_looking_up or is_crouching:
		looktimer += delta
		print(looktimer)
	else:
		looktimer = 0
		
	if is_looking_up and not peelout:
		if looktimer >= 1:
			$Camera2D.offset.y = lerpf($Camera2D.offset.y, -150.0, weight)
	elif is_crouching and not spindashing:
		if looktimer >= 1:
			$Camera2D.offset.y = lerpf($Camera2D.offset.y,  150.0, weight)
	else:
		$Camera2D.offset.y = lerpf($Camera2D.offset.y, 0.0, weight)


# ─────────────────────────────────────────────
# SIGNALS
# ─────────────────────────────────────────────

# TODO: rings aren't being depleted once player touches a badnik
func _on_player_child_entered_tree(area: Area2D) -> void:
	if area.name == "Badnik":
		$RingDrop.play()
		emit_signal("ring_loss")
		velocity.y -= 7000
		velocity.x += last_direction * 500


# ─────────────────────────────────────────────
# PHYSICS
# ─────────────────────────────────────────────

func _physics_process(delta: float) -> void:


	# Kill plane
	if position.y > 1000:
		position.x = 0
		position.y = -100

	_gravity(delta)
	get_input()
	camera_handler(delta)

	# Hitbox visibility on jump
	if Input.is_action_just_pressed("Jump") and not spindashing:
		$ball.visible   = true
		$player.visible = false
	elif is_on_floor():
		$ball.visible   = false
		$player.visible = true

	# Variable jump height
	if not Input.is_action_pressed("Jump") and velocity.y < 0:
		velocity.y *= 0.3

	# Speed timer — counts while running freely, resets when stopping/jumping/rolling
	direction = Input.get_axis("Left", "Right")
	previous_direction()

	if direction != 0 and abs(velocity.x) > 50 and not ball and not spindashing:
		speedtimer += delta
	else:
		speedtimer        = 0.0
		sonicboombool     = false
		sonicboom_sustain = false
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Master"), 0, false)

	# ── Movement / acceleration ──
	if spindashing and is_on_floor() and Input.is_action_pressed("Down"):
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	else:
		if direction != 0.0:
			if direction * velocity.x < 0.0:
				velocity.x = move_toward(velocity.x, direction * run_speed, turn_acceleration * delta)
			else:
				velocity.x = move_toward(velocity.x, direction * run_speed, acceleration * delta)

			# Speed boost + sonic boom trigger
			if speedtimer >= 3.0:
				run_speed = 1300.0
				if not sonicboom_sustain:
					sonicboombool     = true
					sonicboom_sustain = true
					hit_stop(0.05, 0.6)
					$sonicboom.play()
					$Shockwave.emitting = true
					
					# Fade phaser in
					AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Master"), 0, true)
				else:
					sonicboombool = false
			else:
				run_speed = 800.0
		else:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# ── Skidding ──
	if is_on_floor() and not ball and not spindashing:
		is_skidding = direction != 0.0 and velocity.x != 0.0 \
			and direction * velocity.x < 0.0 \
			and abs(velocity.x) > run_threshold
	else:
		is_skidding = false

	# ── Rolling ──
	if is_on_floor() and Input.is_action_pressed("Down") and abs(velocity.x) > 200.0 and not spindashing:
		ball = true

	if ball:
		$ball.visible   = true
		$player.visible = false
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		if abs(velocity.x) < 50.0 or not is_on_floor():
			ball = false

	# ── Stomp ──
	if not is_on_floor() and not is_stomping and Input.is_action_just_pressed("Stomp or Bounce"):
		is_stomping = true
		ball        = false
		velocity.y  = STOMP_SPEED

	if is_on_floor() and is_stomping:
		is_stomping = false

	gravity = STOMP_GRAVITY if is_stomping else NORMAL_GRAVITY

	move_and_slide()
	animation_handler()


# ─────────────────────────────────────────────
# ANIMATION
# ─────────────────────────────────────────────

func animation_handler() -> void:
	var anim := ""
	var jump_held := Input.is_action_pressed("Jump")

	if is_stomping and not is_on_floor():
		anim = "stomp"
	elif not is_stomping and not is_on_floor():
		anim = "jump"
	elif is_crouching and not spindashing:
		anim = "down"
	elif peelout:
		anim = "peelout" 
	elif is_looking_up:
		anim = "look_up"
	elif is_skidding:
		anim = "skid"
	elif spindashing:
		anim = "spindash_rev" if jump_held else "spindash"
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


# ─────────────────────────────────────────────
# SOUND
# ─────────────────────────────────────────────

func sound_handler(anim: String) -> void:
	$Shockwave.emitting = false

	match anim:
		"peelout":
			$peelout.play()
		"jump":
			$jump.play()
			await get_tree().create_timer(0.24).timeout
			$spin.play()
			$CPUParticles2D.emitting = false

		"skid":
			$skid.play()
			$CPUParticles2D.emitting = false

		"walk":
			$wind.stop()
			$Camera2D.offset.x = 0
			$CPUParticles2D.emitting = false

		"jog":
			$wind.stop()
			$CPUParticles2D.emitting = false

		"run":
			$wind.play()
			$CPUParticles2D.emitting = false

		"max_run":
			$Trail2D.is_emitting = true
			$CPUParticles2D.emitting = true

		"spindash_rev", "roll":
			$roll.play()

		"default":
			$footstep.stop()
			$Trail2D.is_emitting = false
			$CPUParticles2D.emitting = false
