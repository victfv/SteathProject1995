extends Spatial

var timer = 0.0
var tracking = false
var playerInArea = false
var scoutAngle = 60
onready var player = MasterScript.player
var suspicionLevel = 0.0

onready var dss = get_world().direct_space_state

const minR = PI/2
const maxR = PI + PI/2

func _physics_process(delta):
	if playerInArea:
		if (player.camY.global_transform.origin - global_transform.origin).normalized().dot($CamY/CameraMesh.global_transform.basis.z) > 0.92:
			var res = dss.intersect_ray(global_transform.origin, player.camY.global_transform.origin, [], 3)
			if res.has("collider") and res.collider == player:
				tracking = true
				$CamY/CameraMesh/Light.material_override.emission = Color.red
			else:
				$CamY/CameraMesh/Light.material_override.emission = Color.green
		else:
			$CamY/CameraMesh/Light.material_override.emission = Color.green
	
	if !tracking:
		timer += delta
		$CamY.rotation.y = sin(timer) * deg2rad(scoutAngle) + PI
	else:
		$LookDummy.look_at(player.global_transform.origin, Vector3.UP)
		$CamY.rotation.y = lerp_angle($CamY.rotation.y, clamp($LookDummy.rotation.y + PI, minR, maxR), delta * 3)


func _on_DetectionArea_body_entered(body):
	playerInArea = true
	print ("see player")


func _on_DetectionArea_body_exited(body):
	playerInArea = false
