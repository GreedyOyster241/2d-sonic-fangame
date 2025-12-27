extends Node

func _ready() -> void:
	$titlemusic.play()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Start") or Input.is_action_just_pressed("Jump"):
		_on_play_pressed()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Levels/level2.tscn")
