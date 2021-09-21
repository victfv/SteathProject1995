extends Spatial


export var docName = "Document"
export var docText = "Document Text"
export var description = "Document"

func interacted(state):
	if state:
		Journal.addDocument(docName, docText)
		queue_free()
