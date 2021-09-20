extends CanvasLayer


func open():
	$Journal.visible = true

func _on_ButtonObjectives_pressed():
	$Journal/TextureRect/MarginContainer/Objectives.visible = true
	$Journal/TextureRect/MarginContainer/Menu.visible = false


func _on_ButtonClose_pressed():
	$Journal.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false


func _on_ButtonDocs_pressed():
	$Journal/TextureRect/MarginContainer/Documents.visible = true
	$Journal/TextureRect/MarginContainer/Menu.visible = false


func _on_Documents_rtrn():
	$Journal/TextureRect/MarginContainer/Documents.visible = false
	$Journal/TextureRect/MarginContainer/Menu.visible = true


func _on_Objectives_rtrn():
	$Journal/TextureRect/MarginContainer/Objectives.visible = false
	$Journal/TextureRect/MarginContainer/Menu.visible = true


func addObjective(objectiveText):
	$Journal/TextureRect/MarginContainer/Objectives.addObjective(objectiveText)

func addDocument(docName, docText):
	$Journal/TextureRect/MarginContainer/Documents.addDoc(docName, docText)
