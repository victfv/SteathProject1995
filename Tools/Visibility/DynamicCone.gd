tool

extends Spatial

export var fov = 45 setget setCone
export (Material) var mat setget updMat

onready var cone = weakref($ViewCone)

func updMat(a):
	mat = a
	if is_instance_valid(cone):
		$ViewCone.material_override = mat

func setCone(a):
	fov = a
	if is_instance_valid(cone):
		var scl = (1/cos(deg2rad(fov)))*sin(deg2rad(fov))
		$ViewCone.scale.x = scl
		$ViewCone.scale.z = scl


func _ready():
	if is_instance_valid(cone):
		$ViewCone.material_override = mat
		var scl = (1/cos(deg2rad(fov)))*sin(deg2rad(fov))
		$ViewCone.scale.x = scl
		$ViewCone.scale.z = scl
