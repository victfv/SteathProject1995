extends Spatial


export (Array, NodePath) var doors
export var description = "Key"

func interacted(state):
	if state:
		for i in doors:
			get_node(i).locked = false
		queue_free()
