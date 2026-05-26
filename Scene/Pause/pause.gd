extends CanvasLayer

var pausebool: bool = false

func _ready() -> void:
	hide()  # Hide pause screen on start


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Start"):
		_toggle_pause()

func _toggle_pause() -> void:
	pausebool = !pausebool  # Flip true/false

	get_tree().paused = pausebool

	if pausebool:
		show()
	else:
		hide()

func _on_resume_pressed() -> void:
	print("pressed")
	get_tree().paused = false
	pausebool = false
	hide()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	pausebool = false
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().quit()
