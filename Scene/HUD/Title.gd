extends Node

func _ready() -> void:
	
	$titlemusic.play()
	$BG.play("default")
	$AnimationPlayer.play("StartUp")
	

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Start") or Input.is_action_just_pressed("Jump"):
		_on_play_pressed()
	
	if $AnimationPlayer.is_playing():
		$Main/Play.disabled = true
		$Main/Settings.disabled = true
		$Main/Exit.disabled = true
		$Settings/Back.disabled = true
	else:
		$Main/Play.disabled = false
		$Main/Settings.disabled = false
		$Main/Exit.disabled = false
		$Settings/Back.disabled = false

func _on_play_pressed() -> void:
	$titlemusic.stop()
	$select.play()
	$AnimationPlayer.play("Black Fade In")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scene/Levels/TestLevel/TestLevel.tscn")




func _on_play_mouse_entered() -> void:
	if !$AnimationPlayer.is_playing():
		$hover.play()


func _on_settings_pressed() -> void:
	$titlemusic.stop()
	$AnimationPlayer.play("TitleFadeAway")
	$AnimationPlayer2.play("IntoSettings")
	await get_tree().create_timer(.5).timeout
	$OptionsScreen.play()


func _on_settings_mouse_entered() -> void:
	if !$AnimationPlayer.is_playing():
		$hover.play()


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	$select.play()
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		



func _on_vsync_toggled(toggled_on: bool) -> void:
	$select.play()
	if toggled_on == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_back_settings_pressed() -> void:
	$select.play()
	$AnimationPlayer.play("TitleFadeIn")
	$AnimationPlayer2.play("OutOfSettings")
	$OptionsScreen.stop()
	$titlemusic.play()
	

func _on_back_settings_mouse_entered() -> void:
	if !$AnimationPlayer.is_playing():
		$hover.play()


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Master'), linear_to_db(value))


func _on_volume_drag_ended(value_changed: bool) -> void:
	if value_changed == true:
		$"ERROR LOL".play()


func _on_exit_mouse_entered() -> void:
	if !$AnimationPlayer.is_playing():
		$hover.play()


func _on_exit_pressed() -> void:
	get_tree().quit()
