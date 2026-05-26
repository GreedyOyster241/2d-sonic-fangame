extends Area2D

var boom = false


func _ready() -> void:
	$".".monitoring = true
	$".".monitorable = true
	boom = false

func _physics_process(_delta: float) -> void:
	if boom == true:
		$Explosion.visible = true
		$".".monitoring = false
		$".".monitorable = false
	else:
		$Explosion.visible = false
		
		

func _on_body_entered(_body: Node2D) -> void:
	$boom.play()
	boom = true
	await get_tree().create_timer(0.7).timeout
	queue_free()
