extends Control

signal rtrn

const doc = preload("res://UI/Journal/Document.tscn")

func _on_Return_pressed():
	emit_signal("rtrn")

func _on_DocReader_rtrn():
	$DocReader.visible = false
	$DocsContainer.visible = true

func openDoc(docName, docText):
	$DocReader.openDoc(docName, docText)
	$DocsContainer.visible = false
	$DocReader.visible = true

func addDoc(docName, docText):
	var nDoc = doc.instance()
	nDoc.docName = docName
	nDoc.docText = docText
	$DocsContainer/ScrollContainer/DocsList.add_child(nDoc)
