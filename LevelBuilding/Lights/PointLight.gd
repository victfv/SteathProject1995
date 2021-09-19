tool

extends OmniLight

export var lightRange = 5 setget updRange

func setState(state):
	if state:
		visible = true
		if $Area.get_overlapping_bodies().size() > 0:
			MasterScript.player.addLight(self)
	else:
		visible = false
		MasterScript.player.removeLight(self)

func updRange(a):
	lightRange = a
	omni_range = lightRange
	$Area/CollisionShape.shape.radius = lightRange

func _on_Area_body_entered(_body):
	MasterScript.player.addLight(self)

func _on_Area_body_exited(_body):
	MasterScript.player.removeLight(self)
