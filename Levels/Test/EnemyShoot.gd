extends Spatial

var Bullet = preload("res://Bullet.tscn")
var damage = 1
var canSee = false
onready var player = $"../../../Player"
onready var parent = $"../../Enemy" #Enemy who owns this gun

func shoot(canSeePassIn, _visStrength):
	canSee = canSeePassIn

var maxCountdown = 500
var index = 50
func _process(_delta):
	if(canSee and parent.movementState != 2):
		if(index > 0):
			index -= 1
		else:
			index = maxCountdown
			var new_bullet = Bullet.instance()
			new_bullet.set_collision_layer_bit( 4, false )
			new_bullet.set_collision_layer_bit( 3, false )
			new_bullet.set_collision_layer_bit( 2, false )
			new_bullet.set_collision_layer_bit( 1, false )
			new_bullet.get_node("CollisionShape").scale.x = 0.1
			new_bullet.get_node("CollisionShape").scale.y = 0.1
			new_bullet.get_node("CollisionShape").scale.z = 0.1
			get_tree().get_root().add_child(new_bullet)
			new_bullet.global_transform = global_transform
			new_bullet.speed = -10
			new_bullet.damage = damage
