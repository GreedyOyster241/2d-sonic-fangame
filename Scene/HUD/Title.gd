extends Node

func _ready() -> void:
	$titlemusic.play()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Levels/level2.tscn")
