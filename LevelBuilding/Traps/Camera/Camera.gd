extends Spatial

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

func _physics_process(delta):
	$LookDummy.look_at(player.global_transform.origin, Vector3.UP)
	$Label.text = str(PI - $LookDummy.rotation.y)
	if !stop:
		if !tracking:
			timer += delta
			if timer >= PI*2:
				timer = 0
			rot = cos(timer) * deg2rad(scoutAngle)
			$CamY.rotation.y = rot
		else:
			#$LookDummy.look_at(player.global_transform.origin, Vector3.UP)
			$CamY.rotation.y = lerp_angle($CamY.rotation.y, clamp($LookDummy.rotation.y - PI, -deg2rad(scoutAngle), deg2rad(scoutAngle)), delta * 6)
			#timer = acos(deg2rad(scoutAngle)/$CamY.rotation.y)


func _on_TrackTimer_timeout():
	#timer = $CamY.rotation.y/(PI)
	stop = false


func _on_Vision_seesPlayer(sees):
	if sees:
		tracking = true
		stop = false
	else:
		if tracking:
			stop = true
			$Timers/TrackTimer.start(2)
			tracking = false
	#print ("see :" + str(sees))
