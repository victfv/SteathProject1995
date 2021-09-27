extends MeshInstance

var locked = true

func interacted(state):
	if state and !locked:
		$Elevator.open()
