tool

extends SpotLight

export var lightRange = 5 setget updRange

var playerInSpot = false # Variable that makes it so signal is emited only once player enters/leaves spot
var playerSpotFalloff = 0.0

func setState(state):
	if state:
		visible = true
		if $Area.get_overlapping_bodies().size() > 0:
			MasterScript.player.addLight(self)
	else:
		$SpotLight.visible = false
		MasterScript.player.removeLight(self)

func updRange(a):
	lightRange = a
	spot_range = lightRange
	$Area/CollisionShape.shape.radius = lightRange

func _ready():
	set_physics_process(false)

func _physics_process(_delta):
	if !Engine.editor_hint:
		var dot = (global_transform.origin - MasterScript.player.global_transform.origin).normalized().dot(global_transform.basis.z.normalized())
		dot = acos(dot)
		#print(rad2deg(dot))
		if dot < deg2rad(spot_angle + 2): # Tests if player is in spotlight
			playerSpotFalloff = clamp((deg2rad(spot_angle + 2) - dot) * 5, 0, 1)
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
