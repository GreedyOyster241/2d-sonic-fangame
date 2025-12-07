extends Node

#var ringCount: int = $Hud/Ring_/RingAmt.text

var is_blinking_zero := false

func _physics_process(delta: float) -> void:
	if $Hud/Ring_/RingAmt.text == "0":
		if not is_blinking_zero:
			is_blinking_zero = true
			blink_zero()
	else:
		is_blinking_zero = false
		$Hud/Ring_/RingAmt.modulate = Color.WHITE


func blink_zero() -> void:
	while is_blinking_zero:
		$Hud/Ring_/RingAmt.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout
		if not is_blinking_zero:
			break
		$Hud/Ring_/RingAmt.modulate = Color.WHITE
		await get_tree().create_timer(0.2).timeout





func ring_collected() -> void:
	$Hud/Ring_/RingAmt.text = str(int($Hud/Ring_/RingAmt.text) + 1)
