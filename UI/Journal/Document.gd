extends Control

export var docName = ""
export var docText = ""

signal openDoc(docName, docText)

func _ready():
	$CenterContainer/Button.text = docName
	var docs = get_parent().get_parent().get_parent().get_parent()
	print(connect("openDoc", docs, "openDoc") == OK)


func _on_Button_pressed():
	emit_signal("openDoc", docName, docText)
