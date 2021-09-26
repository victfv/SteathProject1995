extends Spatial

var damageAmount = 2

func explode(area):
	if(area.name == "Player"):
		area.damage(damageAmount)
		
		var audiostream = AudioStreamPlayer.new()
		audiostream.name = "Big Boomy"
		audiostream.stream = load("res://SFX/Explosion.wav")
		get_tree().get_root().add_child(audiostream)
		audiostream.play()
		
		self.queue_free()
		
