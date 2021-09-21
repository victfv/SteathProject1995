extends Control


func changeScene(sceneName):
	if(sceneName=="Test"):
		get_tree().change_scene("res://Levels/Test/TestLevel.tscn")
