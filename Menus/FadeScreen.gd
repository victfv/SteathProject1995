extends Control

func fade():
	$AnimationPlayer.play("fade_to_black")
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://Menus/End.tscn")
