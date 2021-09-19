extends Node


func _ready():
	$MusicPlayer1.stream = load("res://Music/sneaking.mp3")
	$MusicPlayer1.play()
