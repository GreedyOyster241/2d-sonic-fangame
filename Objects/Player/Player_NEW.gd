extends CharacterBody2D

var direction = Input.get_axis("Left", "Right")

#Gravity
func _gravity(delta) -> void:
	velocity.y += get_gravity() * delta

if direction:
	velocity.x = approach(velocity.x, max_speed * direction, acc)
else:
	velocity.x = approach(velocity.x, 0, fric)

if time_elapsed > 70
	max_speed = 900
	acc = 5
else:
	max_speed = 400
	acc = 15


if jump and is_on_floor():
	velocity.y = jump_velocity

if jump and velocity.y < 0:
	velocity.y = (velocity.y / 2) + 10
	
	

if is_on_floor() and down and abs(velocity.x) > 199
	ball = true
	$AnimatedSprite2d.play("roll")

if ball:
	velocity.x = approach(velocity.x, 0, fric/4)
	
if down and is_on_floor() and velocity.x == 0:
	if jump:
		charge_spin_dash()

func charge_spin_dash():
	#play anim
	speed_charge += 100
	speed_charge = clamp(speed_charge, 200, 1000)
