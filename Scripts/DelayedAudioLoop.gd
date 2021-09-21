extends AudioStreamPlayer3D



# Called when the node enters the scene tree for the first time.
func _ready():
	audio_loop()



func audio_loop():
	while(true):
		play()
		yield(get_tree().create_timer(1), "timeout")
