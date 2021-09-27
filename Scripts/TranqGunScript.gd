extends Spatial


export var damage = 1
var speed = -800
var maxRounds = 2
var currentRounds = 2
var reloading = false

var bullet_scn = preload("res://Bullet.tscn")
var shotsfx = load("res://SFX/silencedTranq.wav") 
var reloadsfx = load("res://SFX/pistolReload.wav")

onready var hud = get_node("../../../../../HUD")

func _ready():
	hud.updateAmmo(currentRounds)

func primary(state):
	if state:
		if(currentRounds > 0):
			currentRounds -= 1
			hud.updateAmmo(currentRounds)
			var new_bullet = bullet_scn.instance()
			new_bullet.set_collision_layer_bit( 5, true )
			new_bullet.set_collision_layer_bit( 4, false )
			new_bullet.set_collision_layer_bit( 3, false )
			new_bullet.set_collision_layer_bit( 2, false )
			new_bullet.set_collision_layer_bit( 1, false )
			new_bullet.global_transform = $Body/SpawnPoint.global_transform
			new_bullet.speed = speed
			new_bullet.damage = damage
			get_tree().get_root().add_child(new_bullet)
			get_child(0).play()
			if(currentRounds <= 0):
				if(!reloading):
					reload()
			
func reload():
	reloading = true
	hud.updateAmmo("R")
	yield(get_child(0), "finished")
	get_child(0).stream = reloadsfx
	get_child(0).play()
	yield(get_child(0), "finished")
	currentRounds = maxRounds
	reloading = false
	get_child(0).stream = shotsfx
	hud.updateAmmo(currentRounds)
	
