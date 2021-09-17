tool

extends Spatial

signal seesPlayer(canSee, power)

export var enabled = true
export var visionConeHalfAngle = 60 setget updAngle
export var visibilityThreshold = 0.23
export var visibilityRange = 20 setget updRange

onready var dss = get_world().direct_space_state
var visibilityStrength = 0.0

var canSeePlayer = false

func updRange(a):
	visibilityRange = a
	$CollisionShape.shape.radius = visibilityRange

func updAngle(a):
	visionConeHalfAngle = a
	if Engine.editor_hint:
		$Arrow/Angle.rotation.z = deg2rad(visionConeHalfAngle)

func _enter_tree():
	set_physics_process(false)

func _ready():
	if !Engine.editor_hint:
		$Arrow.visible = false

func _physics_process(delta):
	if !Engine.editor_hint and enabled:
		$Label.text = str(visibilityStrength)
		var dot = (MasterScript.player.camY.global_transform.origin - global_transform.origin).normalized().dot(global_transform.basis.z.normalized())
		if acos(dot) < deg2rad(visionConeHalfAngle) and MasterScript.player.visibilityLevel > 0:
			var res = dss.intersect_ray(global_transform.origin, MasterScript.player.camY.global_transform.origin, [], 3, true, false)
			calculateVisibilityStength()
			if res.has("collider") and res.collider == MasterScript.player:
				if !canSeePlayer:
					if visibilityStrength > visibilityThreshold:
						canSeePlayer = true
						emit_signal("seesPlayer", canSeePlayer, visibilityStrength)
				else:
					if visibilityStrength < visibilityThreshold:
						canSeePlayer = false
						emit_signal("seesPlayer", canSeePlayer, visibilityStrength)
			else:
				if canSeePlayer:
					canSeePlayer = false
					emit_signal("seesPlayer", canSeePlayer, visibilityStrength)
		else:
			if canSeePlayer:
				canSeePlayer = false
				emit_signal("seesPlayer", canSeePlayer, visibilityStrength)

func calculateVisibilityStength():
	var vis = (MasterScript.player.camY.global_transform.origin - global_transform.origin).length()
	vis = range_lerp(clamp(vis,0,visibilityRange), 0, visibilityRange, 1, 0)
	var vissq = pow(vis,2)
	visibilityStrength = vissq * MasterScript.player.visibilityLevel

func _on_Vision_body_entered(body):
	set_physics_process(true)


func _on_Vision_body_exited(body):
	set_physics_process(false)
	canSeePlayer = false
	emit_signal("seesPlayer", canSeePlayer, 0)