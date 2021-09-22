extends Spatial

var progress = 0.0
var opening = false
var orgn = Vector3()
var alpha = 0.0
var step = 0
var inOut = 0

func _ready():
	set_physics_process(false)

func climbIn(state):
	opening = state
	inOut = 0
	if !state:
		progress = 0

func climbOut(state):
	if state:
		inOut = 1

func _physics_process(delta):
	match inOut:
		0:
			match step:
				0:
					if opening:
						progress = min(progress + delta * 0.5, 1.0)
					if progress == 1:
						MasterScript.player.immobilized = true
						MasterScript.player.crouchToggle()
						orgn = MasterScript.player.global_transform.origin
						$Cover.collision_layer = 0
						step = 1
				1:
					interpTo($ClimbPos.global_transform.origin, delta, 2)
					if alpha == 1:
						step = 2
						orgn = MasterScript.player.global_transform.origin
						alpha = 0.0
				2:
					interpTo($InPos.global_transform.origin, delta, 1)
					if alpha == 1:
						resetClimb()
		1:
			match step:
				0:
					MasterScript.player.immobilized = true
					orgn = MasterScript.player.global_transform.origin
					$Cover.collision_layer = 0
					step = 1
				1:
					interpTo($InPos.global_transform.origin, delta, 3)
					if alpha == 1:
						step = 2
						orgn = MasterScript.player.global_transform.origin
						alpha = 0.0
				2:
					interpTo($ClimbPos.global_transform.origin, delta, 1)
					if alpha == 1:
						resetClimb()

func interpTo(pos, delta, speed):
	alpha = min(alpha + delta * speed, 1.0)
	MasterScript.player.global_transform.origin = lerp(orgn, pos, alpha)

func resetClimb():
	opening = false
	step = 0
	progress = 0
	alpha = 0
	inOut = 0
	$Cover.collision_layer = 1
	MasterScript.player.immobilized = false

func _on_PlayerDetectionArea_body_entered(body):
	set_physics_process(true)


func _on_PlayerDetectionArea_body_exited(body):
	set_physics_process(false)
