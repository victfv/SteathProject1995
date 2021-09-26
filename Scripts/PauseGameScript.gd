extends Control

var paused = false


func _input(_event):
	if Input.is_action_just_pressed("PAUSE"):
		if(paused):
			resume()
		else:
			startPause()


func startPause():
	self.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.visible = true
	paused = true
	get_tree().paused = true
	
func resume():
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = false
	paused = false
	get_tree().paused = false
	
func goToMainMenu():
	get_tree().paused = false
	get_tree().change_scene("res://Menus/MainMenu.tscn")

func quit():
	get_tree().quit()
