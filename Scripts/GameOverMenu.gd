extends Control

onready var hoverAudio = load("res://SFX/interface-hover.mp3")
onready var selectAudio = load("res://SFX/interface-select.mp3")
export(String) var levelRestartPath

func restart():
	playAudio(selectAudio)
	get_tree().paused = false
	get_tree().change_scene(levelRestartPath)

func goToMainMenu():
	playAudio(selectAudio)
	get_tree().paused = false
	get_tree().change_scene("res://Menus/MainMenu.tscn")

func startGameOver():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	visible = true

func playAudio(audioClip):
	var audioStream = AudioStreamPlayer.new()
	audioStream.stream = audioClip
	get_tree().get_root().add_child(audioStream)
	audioStream.play(0.0)
	
func onHover():
	playAudio(hoverAudio)


func _process(delta):
	if MasterScript.alertLevel > 0.99:
		startGameOver()
		MasterScript.gameOver()
