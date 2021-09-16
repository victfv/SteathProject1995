#This script uses a mask and a raytrace to simulate a laser being stoped by a wall
#TODO damage
extends Spatial


onready var raycast = $RayCast
onready var laser_mask = $CSGCombiner/BeamMask


func _process(_delta):
	var object = raycast.get_collider();
	var hitpoint = raycast.get_collision_point();
	
	if object != null:
		laser_mask.height = hitpoint.distance_to(laser_mask.global_transform.origin) * 2
		print("F")
	else:
		laser_mask.height = 0.01
