extends Control

signal rtrn


func addObjective(text):
	var lbl = Label.new()
	$VBoxContainer/ScrollContainer/VBoxContainer.add_child_below_node($VBoxContainer/ScrollContainer/VBoxContainer/Spacer, lbl)
	lbl.text = text

func _on_Return_pressed():
	emit_signal("rtrn")
