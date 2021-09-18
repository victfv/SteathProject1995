extends Control

signal rtrn

func _on_Return_pressed():
	emit_signal("rtrn")


func _on_DocReader_rtrn():
	$DocReader.visible = false
	$DocsContainer.visible = true

func openDoc(docName, docText):
	print("aaa")
	$DocReader.openDoc(docName, docText)
	$DocsContainer.visible = false
	$DocReader.visible = true
