tool

extends Area

export var interactFunction = ""
export var collisionExtents = Vector3(1,1,1) setget updEx

func updEx(a):
	collisionExtents = a
	$CollisionShape.shape.extents = collisionExtents

func interacted(state):
	get_parent().call(interactFunction, state)
	#print ("called " + interactFunction)
