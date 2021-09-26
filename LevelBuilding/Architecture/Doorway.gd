tool

extends Spatial


export var locked = false
export (Material) var mat1 setget updm1
export (Material) var mat2 setget updm2


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
