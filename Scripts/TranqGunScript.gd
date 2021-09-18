extends Spatial


export var damage = -1
export var speed = 50

var bullet_scn = preload("res://Bullet.tscn")

func _input(_event):
	if Input.is_action_just_pressed("useGadget"):
		var new_bullet = bullet_scn.instance()
		get_tree().get_root().add_child(new_bullet)
		new_bullet.global_transform = $Body/SpawnPoint.global_transform
		new_bullet.speed = speed
		new_bullet.damage = damage
