tool

extends Spatial

export var staticCamera = false
export var fov = 30 setget updfov

var timer = 0.0
var tracking = false
var playerInArea = false
var stop = false
var scoutAngle = 80
var rot = 0
onready var player = MasterScript.player
var suspicionLevel = 0.0

onready var dss = get_world().direct_space_state

const minR = PI/2
const maxR = PI + PI/2

func updfov(a):
	fov = a
	if Engine.editor_hint:
		var scl = (1/cos(deg2rad(fov)))*sin(deg2rad(fov))
		$CamY/CameraMesh/ViewConeScaler/ViewCone.scale.x = scl
		$CamY/CameraMesh/ViewConeScaler/ViewCone.scale.z = scl
		$CamY/CameraMesh/Vision.visionConeHalfAngle = fov

func _physics_process(delta):
	if !Engine.editor_hint:
		if !stop:
			if !tracking and !staticCamera:
				timer += delta
				rot = cos(timer) * deg2rad(scoutAngle)
				suspicionLevel = clamp(suspicionLevel - delta * 0.2, 0, 1)
				$CamY.rotation.y = rot
			else:
				var dist = $CamY/CameraMesh/Vision.visibilityStrength
				$Label.text = str(dist)
				suspicionLevel = clamp(suspicionLevel + delta * 2 * dist * player.visibilityLevel, 0, 1)
				if !staticCamera:
					$LookDummy.look_at(player.global_transform.origin, Vector3.UP)
					$CamY.rotation.y = lerp_angle($CamY.rotation.y, clamp($LookDummy.rotation.y - PI * sign($LookDummy.rotation.y), -deg2rad(scoutAngle), deg2rad(scoutAngle)), delta * 6)
					timer = acos($CamY.rotation.y/(deg2rad(scoutAngle)))
		
		$CamY/CameraMesh/Light.material_override.emission = lerp(Color.green, Color.red, suspicionLevel)


func _on_TrackTimer_timeout():
	#timer = $CamY.rotation.y/(PI)
	stop = false


func _on_Vision_seesPlayer(sees, strength):
	print(strength)
	if sees:
		tracking = true
		stop = false
	else:
		if tracking:
			stop = true
			$Timers/TrackTimer.start(2)
			tracking = false
	#print ("see :" + str(sees))
