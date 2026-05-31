extends Area2D

# Variables
var collected = false

# Signals
signal ring_collected

# Physics process
func _ready() -> void:
	$AnimatedSprite2D.play("default")
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		ring_collected.connect(hud._on_ring_collected)
	print(collected)
	

# Handle collisions with the player
# Could Possibly have errors where 
func _on_body_entered(_body: Node2D) -> void:
	print("ring collected!")
	if !collected:
		collected = true
		emit_signal("ring_collected")
		$sfx_ring.play(0.1)
		$AnimatedSprite2D.play("collect")
		await get_tree().create_timer(0.55).timeout
		queue_free() # Remove the ring from the scene
