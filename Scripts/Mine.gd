extends Spatial

func explode(area):
	if(area.name == "Player"):
		print(area.name + " TODO explode")
		self.queue_free()
