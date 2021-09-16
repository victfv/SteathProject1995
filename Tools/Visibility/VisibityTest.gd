tool

extends Spatial

signal seesPlayer(canSee, power)

export var enabled = true
export var visionConeHalfAngle = 60 setget updAngle

onready var dss = get_world().direct_space_state
onready var player = MasterScript.player
var visibilityStrength = 0.0

var canSeePlayer = false

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
	if !Engine.editor_hint:
		var dot = (player.camY.global_transform.origin - global_transform.origin).normalized().dot(global_transform.basis.z.normalized())
		if acos(dot) < deg2rad(visionConeHalfAngle) and player.visibilityLevel > 0:
			var res = dss.intersect_ray(global_transform.origin, player.camY.global_transform.origin, [], 3, true, false)
			calculateVisibilityStength()
			if res.has("collider") and res.collider == player:
				if !canSeePlayer:
					canSeePlayer = true
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
	var invDist = clamp(1/max((player.camY.global_transform.origin - global_transform.origin).length()/2, 0.001),0,1)
	visibilityStrength = invDist * player.visibilityLevel

func _on_Vision_body_entered(body):
	set_physics_process(true)


func _on_Vision_body_exited(body):
	set_physics_process(false)
	canSeePlayer = false
	emit_signal("seesPlayer", canSeePlayer, 0)
