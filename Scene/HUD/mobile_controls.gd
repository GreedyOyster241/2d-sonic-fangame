extends CanvasLayer


func _ready() -> void:
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		$".".visible = true
	else:
		$".".visible = false
		pass
