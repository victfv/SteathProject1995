extends Control


export var login = ""
export var password = ""




func _on_LoginFailed_Ok():
	$AspectRatioContainer/LoginFailedScreen.visible = false


func _on_OK_pressed():
	if $AspectRatioContainer/LoginScreen/LoginLine.text == login and $AspectRatioContainer/LoginScreen/PasswordLine.text == password:
		pass
	else:
		$AspectRatioContainer/LoginFailedScreen.visible = true
