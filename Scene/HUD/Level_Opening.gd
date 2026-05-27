extends Node2D

#TODO: FIX THIS PLEASE, IT ISNT PLAYING FOR SOME REASON :(
func _ready() -> void:
	await get_tree().create_timer(3).timeout
	$Level_Opening/AnimationPlayer.play("stage-open")
	
