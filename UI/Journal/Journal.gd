extends Control




func _on_ButtonObjectives_pressed():
	$TextureRect/MarginContainer/Objectives.visible = true
	$TextureRect/MarginContainer/Menu.visible = false


func _on_ButtonClose_pressed():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false


func _on_ButtonDocs_pressed():
	$TextureRect/MarginContainer/Documents.visible = true
	$TextureRect/MarginContainer/Menu.visible = false


func _on_Documents_rtrn():
	$TextureRect/MarginContainer/Documents.visible = false
	$TextureRect/MarginContainer/Menu.visible = true


func _on_Objectives_rtrn():
	$TextureRect/MarginContainer/Objectives.visible = false
	$TextureRect/MarginContainer/Menu.visible = true
