extends Area2D

# Variables
var collected = false

# Signals
signal ring_collected

# Physics process
func _ready() -> void:
	$AnimatedSprite2D.play("default")
	

# Handle collisions with the player
# Could Possibly have errors where 
func _on_body_entered(_body: Node2D) -> void:
	if !collected:
		collected = true
		emit_signal("ring_collected")
		$sfx_ring.play(0.1)
		$AnimatedSprite2D.play("collect")
		await get_tree().create_timer(0.55).timeout
		queue_free() # Remove the ring from the scene
