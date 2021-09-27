tool

extends Spatial


export var locked = false
export (Material) var mat1 setget updm1
export (Material) var mat2 setget updm2

var open = false

func interacted(state):
	if state:
		if !locked:
			openClose()
		else:
			jiggle()
	

func openClose():
	if !open:
		open = true
		$AnimationPlayer.play("open")
		$Swivel/DoorBody.collision_layer = 0
	else:
		open = false
		$AnimationPlayer.play_backwards("open")

func jiggle():
	$AnimationPlayer.play("jiggle")

func _ready():
	updMats()

func updMats():
	$WallDoorway.material_override = mat1
	$WallDoorway2.material_override = mat2

func updm1(a):
	mat1 = a
	if is_inside_tree():
		updMats()

func updm2(a):
	mat2 = a
	if is_inside_tree():
		updMats()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "open" and open == false:
		$Swivel/DoorBody.collision_layer = 1
