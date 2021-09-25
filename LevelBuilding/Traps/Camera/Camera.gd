tool

extends Spatial

export var staticCamera = false
export var fov = 30 setget updfov
export var detectionRange = 20 setget updRange
export var cameraSpeed = 1.0

var timer = 0.0
var tracking = false
var playerInArea = false
var stop = false
export var scoutAngle = 80
var rot = 0
var suspicionLevel = 0.0

onready var dss = get_world().direct_space_state

const idle = preload("res://SFX/Camera/camera_idle.wav")
const alert = preload("res://SFX/Camera/camera_alert.wav")

func updRange(a):
	detectionRange = a
	if is_instance_valid($CamY/CameraMesh/Vision):
		$CamY/CameraMesh/Vision.visibilityRange = detectionRange
		$range.scale = Vector3(detectionRange,detectionRange,detectionRange)
		$CamSounds.max_distance = detectionRange

func _ready():
	if !Engine.editor_hint:
		$range.queue_free()
	if is_instance_valid($CamY/CameraMesh/Vision):
		$CamY/CameraMesh/Vision.visionConeHalfAngle = fov
		updCone()

func updfov(a):
	fov = a
	if Engine.editor_hint:
		$CamY/CameraMesh/Vision.visionConeHalfAngle = fov
		updCone()

func updCone():
	$CamY/CameraMesh/DynamicCone.setCone(fov)

func _physics_process(delta):
	if !Engine.editor_hint:
		if !stop:
			if !tracking and !staticCamera:
				timer += delta * cameraSpeed
				rot = cos(timer) * deg2rad(scoutAngle)
				suspicionLevel = clamp(suspicionLevel - delta * 0.2, 0, 1)
				$CamY.rotation.y = rot
			else:
				var dist = $CamY/CameraMesh/Vision.visibilityStrength
				$Label.text = str(dist)
				suspicionLevel = clamp(suspicionLevel + clamp(delta * 2 * MasterScript.player.visibilityLevel, 0.006, 0.015), 0, 1)
				if !staticCamera:
					$LookDummy.look_at(MasterScript.player.global_transform.origin, Vector3.UP)
					$CamY.rotation.y = lerp_angle($CamY.rotation.y, clamp($LookDummy.rotation.y - PI * sign($LookDummy.rotation.y), -deg2rad(scoutAngle), deg2rad(scoutAngle)), delta * 6)
					timer = acos($CamY.rotation.y/(deg2rad(scoutAngle)))
		
		$CamY/CameraMesh/Light.material_override.emission = lerp(Color.green, Color.red, suspicionLevel)


func _on_TrackTimer_timeout():
	#timer = $CamY.rotation.y/(PI)
	$CamSounds.stream = idle
	$CamSounds.play()
	stop = false


func _on_Vision_seesPlayer(sees, _strength):
	$CamSounds.stream = alert
	$CamSounds.play()
	if sees:
		tracking = true
		stop = false
	else:
		if tracking:
			stop = true
			$Timers/TrackTimer.start(2)
			tracking = false
		else:
			$CamSounds.stream = idle
			$CamSounds.play()
