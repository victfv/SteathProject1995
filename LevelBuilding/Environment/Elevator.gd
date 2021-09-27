extends Spatial

var end = false

func open():
	$AnimationPlayer.play("open")

func close(state):
	MasterScript.player.immobilized = true
	$AnimationPlayer.play_backwards("open")
	end = true

func endGame():
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "open" and end:
		endGame()
