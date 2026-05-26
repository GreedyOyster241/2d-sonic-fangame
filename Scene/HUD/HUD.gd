extends Node

#var ringCount: int = $Hud/RingAmt.text


var is_blinking_zero := false
var elapsed_time: float = 0.0




func _physics_process(delta: float) -> void:
	if $Hud/RingAmt.text == "0":
		if not is_blinking_zero:
			is_blinking_zero = true
			blink_zero()
	else:
		is_blinking_zero = false
		$Hud/RingAmt.modulate = Color.WHITE
		
	elapsed_time += delta
	var total_seconds: int = int(elapsed_time)

	var seconds: int = total_seconds % 60
	@warning_ignore("integer_division")
	var mins: int = total_seconds / 60
	var timeamt = $Hud/TimeAmt
	timeamt.text = "%02d:%02d" % [mins, seconds]
	#NOT WORKING TODO: FIX
	#if timeamt.text == "00:05":
		#stop_timer()

func blink_zero() -> void:
	while is_blinking_zero:
		$Hud/RingAmt.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout
		if not is_blinking_zero:
			break
		$Hud/RingAmt.modulate = Color.WHITE
		await get_tree().create_timer(0.2).timeout

func ring_collected() -> void:
	$Hud/RingAmt.text = str(int($Hud/RingAmt.text) + 1)

func ring_loss() -> void:
	if str(int($Hud/RingAmt.text)) != "0":
		$Hud/RingAmt.text = 0

func _ready() -> void:
	$Hud/Timer.start()
	
