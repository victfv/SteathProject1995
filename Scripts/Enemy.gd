extends KinematicBody

export(NodePath) var patrolPoints #Patrol Path
var patrolNode
var nextPatrolIndex = 0 #Next Point Index
var nextPatrolNode #Next node

var path = [] # Path to player
var path_node = 0 #Path index for Player chase

var movementState = 1 # 0 equals chase player, 1 equals follow path, 2 equals asleep

var speed = 2 #Speed of enemy
var timeTillDoze = 1 #Seconds till enemy falls asleep
var lengthOfDoze = 10 #Seconds till doze ends

onready var nav = get_parent() #NavMesh
onready var player = $"../../Player"

func _ready():
	patrolNode = get_node(patrolPoints)
	nextPatrolNode = patrolNode.get_child(nextPatrolIndex)
	path = nav.get_simple_path(global_transform.origin, nextPatrolNode.global_transform.origin)

func _physics_process(_delta):
	if movementState == 0:
		chasePlayer()
	elif movementState == 1:
		followPath()
	elif movementState == 2:
		sleep()


func chasePlayer():
	path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
	if path.size() > 0:
		var direction = (path[1] - global_transform.origin)
		move_and_slide(direction.normalized() * speed, Vector3.UP)
	else:
		print("Arrive")
	lookAtDestination(player.global_transform.origin)

func followPath():
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node +=1
		else:
			move_and_slide(direction.normalized() * speed, Vector3.UP)
			lookAtDestination(global_transform.origin + direction)
	checkIfArrivedAtPoint()

func checkIfArrivedAtPoint():
	if path_node == path.size():
		nextPatrolIndex +=1
		if nextPatrolIndex >= patrolNode.get_child_count():
			nextPatrolIndex = 0
		resetPath()

func lookAtDestination(lookAtTransform):
	var lookAtSpot = lookAtTransform #Deal with look at
	lookAtSpot[1] = global_transform.origin[1]
	if global_transform.origin != lookAtSpot:
		look_at(lookAtSpot, Vector3.UP)

func tranqulize():
	if(movementState!=2):
		#yield(get_tree().create_timer(timeTillDoze), "timeout")
		movementState = 2
		$AudioStreamPlayer3D.pauseLoop()
		$TranqPlayer.play()
		yield(get_tree().create_timer(lengthOfDoze), "timeout")
		$AudioStreamPlayer3D.playLoop()
		movementState = 1
		resetPath()


func resetPath():
	path_node = 0
	nextPatrolNode = patrolNode.get_child(nextPatrolIndex)
	path = nav.get_simple_path(global_transform.origin, nextPatrolNode.global_transform.origin)

func sleep():
	pass
	
func _on_Vision_seesPlayer(canSee, power): #What is like subroutine in unity
	print(canSee)
	if(movementState != 2):
		if canSee:
			movementState = 0
		else:
			movementState = 1
			resetPath()
