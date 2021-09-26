tool

extends KinematicBody

export var pushExtent = 1.0 setget updExt
export var description = "Push"
var beingPushed = false


func updExt(a):
	pushExtent = a
	$InteractionArea.collisionExtents = Vector3(pushExtent,pushExtent,pushExtent)

func _ready():
	set_physics_process(false)

func push(state):
	if state:
		set_physics_process(true)
	else:
		set_physics_process(false)

func _physics_process(delta):
	var dir = MasterScript.player.camY.global_transform.basis.z
	dir.y = 0
	dir = -dir.normalized()
	dir.y = -10
	move_and_slide(dir, Vector3.UP, false, 4, 0.1, false)
