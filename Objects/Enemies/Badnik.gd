extends Area2D

var boom = false
signal badnik_bounce

func _ready() -> void:
	boom = false

func _physics_process(delta: float) -> void:
	if boom == true:
		$Explosion.visible = true
	else:
		$Explosion.visible = false
		
		

func _on_body_entered(_body: Node2D) -> void:
	emit_signal("badnik_bounce")
	$boom.play()
	boom = true
	await get_tree().create_timer(0.7).timeout
	queue_free()
