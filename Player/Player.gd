extends KinematicBody

#controls
var fbrl = Vector2() # fbrl = forwards, backwards, left, right. Used to save movement input
var lean = 0 # Lean weight
var willJump = false #If character should jump on the next physics loop
var movementMode = 0 # 0 = character falling, 1 = character on ground, 2 = swimming (if we implement swimming at all)
var snapVector = Vector3.DOWN # Points towards the ground, for snapping to it
var inWater = false # If the character is in water
var mouseSensitivity = 0.01 # Mouse speed multiplier
var crouching = false # If the character is currently crouching
var immobilized = false

#Velocity
var velocity = Vector3()
var acceleration = 60
var gDamping = 0.22 #Damping for ground movement
var aDamping = 0.01 #Damping for air movement
var gravity = -9.8 # Gravity
var jumpImpulse = 3 #Impulse applied when jumping

#Components
onready var camY = $CamY
onready var hud = $HUD
onready var gameOverMenu = get_node("../GameOverMenu")

#Misc
onready var dss = get_world().direct_space_state #Direct space state, for programatically tracing rays and shapes

#Interaction
var interacting = false
var interactingWith = null

#Gameplay
var lights = []
var visibilityLevel = 0.0

#Health
var maxHealth = 2
var health = maxHealth

func _enter_tree():
	MasterScript.player = self

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Captures mouse in game window
	hud.updateHealth(health)

func _input(event):
	if !immobilized:
		# Uses action strength so that analog movement works
		fbrl = Vector2(Input.get_action_strength("R") - Input.get_action_strength("L"), Input.get_action_strength("BW") - Input.get_action_strength("FW")).clamped(1)
		
		# Jump logic so that holding space will make the character jump continuously
		if Input.is_action_just_released("JUMP"):
			willJump = false
		if Input.is_action_just_pressed("JUMP"):
			willJump = true
		
		# Calls crouch when you press crouch
		if Input.is_action_just_pressed("CROUCH"):
			crouchToggle()
		
		lean = Input.get_action_strength("LEANR") - Input.get_action_strength("LEANL") # Takes input for leaning
		
		#Interaction
		if Input.is_action_just_pressed("INTERACT"):
			interacting = true
		if Input.is_action_just_released("INTERACT"):
			interacting = false
		
		if Input.is_action_just_pressed("JOURNAL"):
			Journal.open()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
		
		if Input.is_action_just_pressed("PRIMARY"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			callPrimary(true)
		if Input.is_action_just_released("PRIMARY"):
			callPrimary(false)
		
		if Input.is_action_just_pressed("SECONDARY"):
			callSecondary(true)
		if Input.is_action_just_released("SECONDARY"):
			callSecondary(false)
		
	if event is InputEventMouseMotion: # If the input even is mouse motion
		mouseLook(event) # Call mouse look and pass the event
	
	#Quit game on exit key pressed
	if Input.is_action_pressed("QUIT"):
		get_tree().quit()

func callPrimary(state):
	if $CamY/CamX/Camera/Equipped.get_child_count() > 0 and $CamY/CamX/Camera/Equipped.get_child(0).has_method("primary"):
			$CamY/CamX/Camera/Equipped.get_child(0).primary(state)

func callSecondary(state):
	if $CamY/CamX/Camera/Equipped.get_child_count() > 0 and $CamY/CamX/Camera/Equipped.get_child(0).has_method("secondary"):
			$CamY/CamX/Camera/Equipped.get_child(0).secondary(state)

const lookLimit = PI/2.1 # Look limit is < 90 degrees

func mouseLook(event):
	$CamY.rotate(Vector3.UP, -event.relative.x * mouseSensitivity) # Rotates CamY in accordance to mouse x axis movement
	$CamY/CamX.rotation.x = clamp($CamY/CamX.rotation.x - event.relative.y * mouseSensitivity, -lookLimit, lookLimit) # Rotates CamX in accordance to mouse y axis movement

func interact():
	var col = $CamY/CamX/Camera/InteractionCast.get_collider()
	if col != null:
		if col.get("description") != null:
			$HUD.display(col.description)
		else:
			$HUD.display("")
		if interacting:
			if interactingWith == null:
				if col.has_method("interacted"):
					interactingWith = col
					interactingWith.interacted(true)
			elif col != interactingWith:
				uninteract()
		else:
			uninteract()
	else:
		$HUD.display("")
		uninteract()

func uninteract():
	if is_instance_valid(interactingWith):
		interactingWith.interacted(false)
	interactingWith = null
	interacting = false
	$HUD.displayRing(0)

func crouchToggle():
	if crouching: # If player is crouching
		#Set up collision test
		var psqp = PhysicsShapeQueryParameters.new()
		psqp.collision_mask = 1
		psqp.exclude = [self]
		psqp.shape_rid = $HeadTest/CollisionShape.shape
		psqp.transform = $HeadTest/CollisionShape.global_transform
		
		var res = dss.intersect_shape(psqp, 1)
		# Test collision
		if res.size() == 0: # If didn't collide
			crouching = false # Stop crouching
			$AnimationPlayer.play_backwards("Crouch") # Play the crouch animation backwards
	else:
		crouching = true # If player is not crouching
		$AnimationPlayer.play("Crouch") # Play the crouch animation

func crouchFinish():
	if crouching:
		$CollisionShape.shape.height = 0.47 # Set collision height to half
		$CollisionShape.transform.origin = Vector3(0,-0.235,0) # Set collision to the floor
	else:
		$CollisionShape.shape.height = 0.94 # Set collision height to full
		$CollisionShape.transform.origin = Vector3() # Set collisiong to the correct position

func _on_AnimationPlayer_animation_finished(anim_name): # Called when an animation finishes
	if anim_name == "Crouch": # If crouch animation finished, call crouchFinish
		crouchFinish()





func _physics_process(delta):
	
	#$Label.text = "Vis level = " + str(visibilityLevel)
	
	mMode()
	if !immobilized:
		hMovement(delta)
		vMovement(delta)
	jump()
	calculateVisibility()
	leanF(delta)
	playerLight(delta)
	interact()
	
	velocity = move_and_slide_with_snap(velocity, snapVector, Vector3.UP, false, 4, PI/3.5, false) # Sets velocity to the result of move and slide with snap
	#snapVector = Vector3.DOWN
	snapVector = -get_floor_normal() # Sets the floor snap vector to negative of the floor normal





func leanF(delta):
	$CamY/CamX/Camera.transform.origin.x = lerp($CamY/CamX/Camera.transform.origin.x, lean * 0.3, delta * 6) # Lerps camera between lean positions
	$CamY/CamX/Camera.rotation.z = lerp($CamY/CamX/Camera.rotation.z, -lean * 0.2, delta * 6)

func jump():
	if willJump and movementMode == 1: # If will jump and is on floor
		snapVector = Vector3() # Nulls snap vector so that player can jump
		velocity.y = jumpImpulse # Sets velocity y to jump impulse, launching character up

func mMode():
	if inWater: # If player is in water
		movementMode = 2
	else: # If player isn't in water
		if is_on_floor(): # If player is touching the floor
			movementMode = 1
		else:
			movementMode = 0

func hMovement(delta): # Horizontal movement
	var dir = $CamY.global_transform.basis.orthonormalized() # Directin in which to move, right now it's just the CamY basis normalized
	dir = fbrl.x * dir.x + fbrl.y * dir.z # Multiply dir x, or the vector that points to the left of the character, by fbrl's x and the forward vectot of the character by fbrl's y
	match movementMode: # Switch statement
		0: # Character is falling
			var velxz = Vector2(velocity.x, velocity.z)
			velxz -= velxz * aDamping # Dampening only x and z axes
			velocity.x = velxz.x
			velocity.z = velxz.y
			velocity += acceleration * 0.05 * dir * delta # Allows a mininal amount of movement while on air
		1: # Character is on ground
			velocity -= velocity * gDamping # Dampens velocity
			velocity += acceleration * (int(crouching) * 0.6 + int(!crouching)) * delta * dir # Adds movement acceleration to velocity
		2:
			pass

func vMovement(delta):
	match movementMode:
		0: # Character is falling
			velocity.y += delta * gravity # Add gravity/sec to velocity's y
		1:
			pass
		2:
			pass





func calculateVisibility():
	visibilityLevel = 0
	for i in range(lights.size()): # Calculates light level and occlusion for each light
		var res = dss.intersect_ray(lights[i].global_transform.origin, camY.global_transform.origin, [], 3)
		if res.has("collider") and res.collider == self:
			if lights[i] is SpotLight:
				visibilityLevel += range_lerp((lights[i].global_transform.origin - camY.global_transform.origin).length(), 0, lights[i].lightRange, 1, 0) * lights[i].playerSpotFalloff
			else:
				visibilityLevel += range_lerp((lights[i].global_transform.origin - camY.global_transform.origin).length(), 0, lights[i].lightRange, 1, 0)
	if crouching:
		visibilityLevel *= 0.85 # Applies crouching modifier
	visibilityLevel = clamp(visibilityLevel, 0, 1) # Clamps visibility level to 0 to 1 range

func addLight(light): # Adds light to light list
	lights.append(light)

func removeLight(light): # Removes light from light list
	lights.erase(light)

func playerLight(delta):
	if visibilityLevel > 0.1:
		$PlayerGlow.light_energy = lerp($PlayerGlow.light_energy, 0,delta * 0.8)
	else:
		$PlayerGlow.light_energy = lerp($PlayerGlow.light_energy, 0.15,delta * 0.2)

func damage(damageAmount):
	health -= damageAmount
	if(health < 0):
		health = 0
	hud.updateHealth(health)
	if(health <= 0):
		gameOverMenu.startGameOver()
