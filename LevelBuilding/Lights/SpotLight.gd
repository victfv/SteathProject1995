tool

extends Spatial

export var lightRange = 5 setget updRange
export var lightAngle = 45 setget updAngle
export var color = Color.white setget updColor
export var shadows = false setget updShadow

var playerInSpot = false

func setState(state):
	if state:
		$SpotLight.visible = true
		if $Area.get_overlapping_bodies().size() > 0:
			MasterScript.player.addLight(self)
	else:
		$SpotLight.visible = false
		MasterScript.player.removeLight(self)

func updColor(a):
	color = a
	$SpotLight.light_color = color

func updShadow(a):
	shadows = a
	$SpotLight.shadow_enabled = shadows

func updRange(a):
	lightRange = a
	$SpotLight.spot_range = lightRange
	$Area/CollisionShape.shape.radius = lightRange

func updAngle(a):
	lightAngle = a
	$SpotLight.spot_angle = lightAngle

func _ready():
	set_physics_process(false)

func _physics_process(_delta):
	if !Engine.editor_hint:
		var dot = (global_transform.origin - MasterScript.player.camY.global_transform.origin).normalized().dot(global_transform.basis.z.normalized())
		if acos(dot) < deg2rad(lightAngle):
			if !playerInSpot:
				playerInSpot = true
				MasterScript.player.addLight(self)
		else:
			if playerInSpot:
				playerInSpot = false
				MasterScript.player.removeLight(self)

func _on_Area_body_entered(_body):
	set_physics_process(true)

func _on_Area_body_exited(_body):
	MasterScript.player.removeLight(self)
	playerInSpot = false
	set_physics_process(false)
