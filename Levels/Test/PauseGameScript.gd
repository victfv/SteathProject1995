extends Control

var paused = false


func _input(event):
	if Input.is_action_just_pressed("pause"):
		if(paused):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
			self.visible = false
			paused = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
			self.visible = true
			paused = true
