extends Control

func restart():
	get_tree().paused = false
	get_tree().change_scene("res://Levels/Test/TestGuardScene.tscn")

func goToMainMenu():
	get_tree().paused = false
	get_tree().change_scene("res://Menus/MainMenu.tscn")

func startGameOver():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	visible = true
