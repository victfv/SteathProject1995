extends AudioStreamPlayer3D

export var timeOutAmount = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_loop()



func audio_loop():
	while(true):
		play()
		yield(get_tree().create_timer(timeOutAmount), "timeout")
