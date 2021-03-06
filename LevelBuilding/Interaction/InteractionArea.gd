tool

extends Area

export var interactFunction = ""
export var collisionExtents = Vector3(1,1,1) setget updEx
export var description = ""
export var enabled = true
export (NodePath) var node = null

var progress = false

func _ready():
	set_physics_process(false)
	if get_parent().get("description") != null:
		description = get_parent().description
	if get_parent().get("progress") != null:
		progress = true

func updEx(a):
	collisionExtents = a
	$CollisionShape.shape.extents = collisionExtents

func _physics_process(delta):
	if node != null:
		MasterScript.player.hud.displayRing(get_node(node).progress)
	else:
		MasterScript.player.hud.displayRing(get_parent().progress)

func interacted(state):
	if enabled:
		if node != null:
			get_node(node).call(interactFunction, state)
		else:
			get_parent().call(interactFunction, state)
		if progress:
			set_physics_process(state)
