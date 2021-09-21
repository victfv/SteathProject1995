extends TextEdit

export var maxLetter = 12

func _ready():
	connect("text_changed", self, "cstr")

func cstr():
	if text.length() > maxLetter:
		var nText = text
		nText.erase(maxLetter,1)
		text = nText
		cursor_set_column(maxLetter)
