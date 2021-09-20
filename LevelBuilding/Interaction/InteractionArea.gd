extends Area

export var interactFunction = ""

func interacted(state):
	get_parent().call(interactFunction, state)
