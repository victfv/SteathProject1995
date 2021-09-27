extends MeshInstance

export (NodePath) var elevbutton

func interacted(state):
	if state:
		get_node(elevbutton).locked = false
		queue_free()
