tool

extends Spatial

export var lightRange = 5 setget updRange
export var color = Color.white setget updColor
export var shadows = false setget updShadow

func setState(state):
	if state:
		$OmniLight.visible = true
		if $Area.get_overlapping_bodies().size() > 0:
			MasterScript.player.addLight(self)
	else:
		$OmniLight.visible = false
		MasterScript.player.removeLight(self)

func updColor(a):
	color = a
	$OmniLight.light_color = color

func updShadow(a):
	shadows = a
	$OmniLight.shadow_enabled = shadows

func updRange(a):
	lightRange = a
	$OmniLight.omni_range = lightRange
	$Area/CollisionShape.shape.radius = lightRange

func _on_Area_body_entered(_body):
	MasterScript.player.addLight(self)

func _on_Area_body_exited(_body):
	MasterScript.player.removeLight(self)
