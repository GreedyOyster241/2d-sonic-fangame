extends Node2D

func _ready():
	get_tree().paused = true
	$AnimationPlayer.play("stage-open")
	$AnimationPlayer.animation_finished.connect(_on_intro_finished)

func _on_intro_finished(anim_name: StringName):
	get_tree().paused = false
	
	
