extends Control

var paused = false
onready var hoverAudio = load("res://SFX/interface-hover.mp3")
onready var selectAudio = load("res://SFX/interface-select.mp3")

func _input(_event):
	if Input.is_action_just_pressed("PAUSE"):
		if(paused):
			resume()
		else:
			startPause()


func startPause():
	self.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.visible = true
	paused = true
	get_tree().paused = true
	playAudio(selectAudio)
	
func resume():
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = false
	paused = false
	get_tree().paused = false
	playAudio(selectAudio)
	
func goToMainMenu():
	get_tree().paused = false
	playAudio(selectAudio)
	get_tree().change_scene("res://Menus/MainMenu.tscn")

func returnToMainPauseMenu():
	$Controls.visible = false
	$Main.visible = true
	
func openControlsMenu():
	$Controls.visible = true
	$Main.visible = false

func quit():
	get_tree().quit()
	
func onHover():
	playAudio(hoverAudio)
	
func playAudio(audioClip):
	var audioStream = AudioStreamPlayer.new()
	audioStream.stream = audioClip
	get_tree().get_root().add_child(audioStream)
	audioStream.play(0.0)
