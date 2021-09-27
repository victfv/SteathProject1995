extends AudioStreamPlayer3D

export(float) var timeOutAmount = 1
var looping = true

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_loop()

func audio_loop():
	while(true):
		yield(get_tree().create_timer(timeOutAmount), "timeout")
		if(looping):
			play()

func pauseLoop():
	looping = false
func playLoop():
	looping = true
