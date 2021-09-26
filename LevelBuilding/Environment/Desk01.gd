extends Spatial

var flpflp = false

func interacted(state):
	if state:
		flpflp = !flpflp
		if flpflp:
			$AnimationPlayer.play("Open")
		else:
			$AnimationPlayer.play_backwards("Open")
