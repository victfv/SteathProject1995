extends Control
onready var hoverAudio = load("res://SFX/interface-hover.mp3")
onready var selectAudio = load("res://SFX/interface-select.mp3")

func changeScene(sceneName):
	playAudio(selectAudio)
	$AnimationPlayer.play("fade_to_black")
	yield(get_tree().create_timer(1), "timeout")
	if(sceneName=="Test"):
		get_tree().change_scene("res://Levels/Test/TestLevel.tscn")

func aboutGame():
	playAudio(selectAudio)
	$MainScreen.visible = false
	$AboutScreen.visible = true
	
func returnToMainMenu():
	playAudio(selectAudio)
	$MainScreen.visible = true
	$AboutScreen.visible = false
	
func quitGame():
	get_tree().quit()

func onHover():
	playAudio(hoverAudio)
	
func playAudio(audioClip):
	var audioStream = AudioStreamPlayer.new()
	audioStream.stream = audioClip
	get_tree().get_root().add_child(audioStream)
	audioStream.play(0.0)
