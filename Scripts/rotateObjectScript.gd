# This class will rotate the object along it's y axis based on the rotSpeed given

extends CSGBox

export var rotSpeed = 0.01


func _process(delta):
	rotate_y(rotSpeed)
