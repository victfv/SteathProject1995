extends Spatial

export (NodePath) var fade
var end = false

func open():
	$AnimationPlayer.play("open")

func close(state):
	MasterScript.player.immobilized = true
	$AnimationPlayer.play_backwards("open")
	end = true

func endGame():
	get_node(fade).fade()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "open" and end:
		endGame()
