extends Control


signal rtrn

func openDoc(docName, docText):
	$VBoxContainer/DocName.text = docName
	$VBoxContainer/ScrollContainer/VBoxContainer/DocText.text = docText


func _on_ButtonReturn_pressed():
	emit_signal("rtrn")
