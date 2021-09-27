extends Node

var world
var player

var alertLevel = 0

func _process(delta):
	alertLevel = clamp(alertLevel - 0.05 * delta, 0, 1)
