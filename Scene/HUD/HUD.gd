extends Node


var ringCount: int = 0
var is_blinking_zero := false
var elapsed_time: float = 0.0

func _ready() -> void:
	add_to_group("hud")
	$Hud/Timer.start()

func _physics_process(delta: float) -> void:
	
	#print($Hud/RingAmt.text)
	if str($Hud/RingAmt.text) == "0":
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

func _on_ring_collected() -> void:
	ringCount += 1
	$Hud/RingAmt.text = str(ringCount)

func ring_loss() -> void:
	if ringCount > 0:
		ringCount = 0
		$Hud/RingAmt.text = "0"
	
